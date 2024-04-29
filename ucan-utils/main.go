// Copyright (C) 2023-2024 StorSwift Inc.
// This file is part of the PowerVoting library.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/filecoin-project/go-address"
	"github.com/filecoin-project/go-crypto"
	goCrypto "github.com/filecoin-project/go-crypto"
	c1 "github.com/filecoin-project/go-state-types/crypto"
	"github.com/minio/blake2b-simd"
	blst "github.com/supranational/blst/bindings/go"
	"github.com/urfave/cli/v2"
	"log"

	"os"
)

const (
	VERSION          = "0.0.1"
	JWT              = "JWT"
	SECP256K1        = "secp256k1"
	BLS              = "bls"
	SigTypeSecp256k1 = 1
	SigTypeBLS       = 2
	DST              = "BLSt_SIG_BLSt12381G2_XMD:SHA-256_SSWU_RO_NUL_"
)

type Header struct {
	Alg     string `json:"alg" bson:"alg"`
	Type    string `json:"type" bson:"type"`
	Version string `json:"version" bson:"version"`
}

type Payload struct {
	Iss string `json:"iss" bson:"iss"`
	Aud string `json:"aud" bson:"aud"`
	Act string `json:"act" bson:"act"`
	Prf string `json:"prf" bson:"prf"`
}

func main() {
	app := &cli.App{
		Name:  "signature",
		Usage: "Use JWT signature with private key and key type",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:  "aud",
				Usage: "Eth address that requires authorization",
			},
			&cli.StringFlag{
				Name:  "act",
				Usage: "Input add or del",
			},
			&cli.StringFlag{
				Name:  "privateKey",
				Usage: "Input the private key against Filecoin address",
			},
			&cli.StringFlag{
				Name:  "keyType",
				Usage: "Input key type, secp256k1 or BLSt",
			},
		},
		Action: func(ctx *cli.Context) error {
			aud := ctx.String("aud")
			act := ctx.String("act")
			privateKey := ctx.String("privateKey")
			keyType := ctx.String("keyType")

			if len(aud) == 0 {
				log.Println("aud cannot be empty. Please enter a value.")
			}
			if len(act) == 0 {
				log.Println("act cannot be empty. Please enter a value.")
			}
			if len(privateKey) == 0 {
				log.Println("privateKey cannot be empty. Please enter a value.")
			}
			if len(keyType) == 0 {
				log.Println("keyType cannot be empty. Please enter a value.")
			}
			signature, err := Signature(aud, act, privateKey, keyType)
			if err != nil {
				log.Println("signature failed!")
				return err
			}
			log.Println("signature success!")
			log.Println(signature)
			return nil
		},
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}

}

func Signature(aud, act, privateKeyStr string, keyTypeStr string) (string, error) {
	switch keyTypeStr {
	case SECP256K1:
		return Secp256k1(aud, act, privateKeyStr)
	case BLS:
		return Bls(aud, act, privateKeyStr)
	}
	return "", errors.New("unknown key type")
}

func Secp256k1(aud, act, privateKeyStr string) (string, error) {
	privateKeyBytes, err := base64.StdEncoding.DecodeString(privateKeyStr)
	if err != nil {
		return "", fmt.Errorf("failed to decode private key: %w", err)
	}

	filecoinAddress, err := address.NewSecp256k1Address(goCrypto.PublicKey(privateKeyBytes))
	if err != nil {
		return "", err
	}

	payload := Payload{
		Iss: filecoinAddress.String(),
		Aud: aud,
		Act: act,
	}

	payloadByte, err := json.Marshal(payload)
	if err != nil {
		return "", fmt.Errorf("failed to marshal payload: %w", err)
	}

	payloadStr := base64.RawURLEncoding.EncodeToString(payloadByte)

	header := Header{
		Alg:     SECP256K1,
		Version: VERSION,
		Type:    JWT,
	}

	headerByte, err := json.Marshal(header)
	if err != nil {
		return "", fmt.Errorf("failed to marshal header: %w", err)
	}

	headerStr := base64.RawURLEncoding.EncodeToString(headerByte)

	b2sum := blake2b.Sum256([]byte(fmt.Sprintf("%s.%s", headerStr, payloadStr)))

	sig, err := crypto.Sign(privateKeyBytes, b2sum[:])
	if err != nil {
		return "", err
	}

	signature := &c1.Signature{
		Data: sig,
		Type: SigTypeSecp256k1,
	}

	signatureStr := base64.RawURLEncoding.EncodeToString(signature.Data)
	return fmt.Sprintf("%s.%s.%s", headerStr, payloadStr, signatureStr), nil
}

func Bls(aud, act, privateKeyStr string) (string, error) {
	privateKeyBytes, err := base64.StdEncoding.DecodeString(privateKeyStr)
	if err != nil {
		return "", fmt.Errorf("failed to decode private key: %w", err)
	}

	privateKey := new(blst.SecretKey).FromLEndian(privateKeyBytes)
	if privateKey == nil || !privateKey.Valid() {
		return "", errors.New("bls signature invalid private key")
	}

	filecoinAddress, err := address.NewBLSAddress(new(blst.P1Affine).From(privateKey).Compress())
	if err != nil {
		return "", err
	}

	payload := Payload{
		Iss: filecoinAddress.String(),
		Aud: aud,
		Act: act,
	}

	payloadByte, err := json.Marshal(payload)
	if err != nil {
		return "", fmt.Errorf("failed to marshal payload: %w", err)
	}

	payloadStr := base64.RawURLEncoding.EncodeToString(payloadByte)

	header := Header{
		Alg:     BLS,
		Version: VERSION,
		Type:    JWT,
	}

	headerByte, err := json.Marshal(header)
	if err != nil {
		return "", fmt.Errorf("failed to marshal header: %w", err)
	}

	headerStr := base64.RawURLEncoding.EncodeToString(headerByte)

	signature := &c1.Signature{
		Data: new(blst.P2Affine).Sign(privateKey, []byte(fmt.Sprintf("%s.%s", headerStr, payloadStr)), []byte(DST)).Compress(),
		Type: SigTypeBLS,
	}

	signatureStr := base64.RawURLEncoding.EncodeToString(signature.Data)
	return fmt.Sprintf("%s.%s.%s", headerStr, payloadStr, signatureStr), nil
}
