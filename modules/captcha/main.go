package main

import (
	"fmt"
	"os"
	"image/jpeg"
	"encoding/json"
	"github.com/steambap/captcha"
	"golang.org/x/image/font/gofont/goregular"
)

func main() {
	err := captcha.LoadFont(goregular.TTF)
	if err != nil {
		panic(err)
	}

	file, err := os.Create("captcha.jpg")
	if err != nil {
		panic(err)
	}
	defer file.Close() // Ensure the file is closed after we're done with it



	img, err := captcha.New(150, 50, func(options *captcha.Options) {
		options.FontScale = 0.8
		options.CharPreset = "0987654321"
		options.TextLength = 6
	})


	var op jpeg.Options;
	op.Quality = 64
	err = img.WriteJPG(file, &op)

	fullPath, _ := os.Getwd()
	fullPath = fullPath + "/captcha.jpg"

	jsonData := struct {
		Path string `json:"path"`
		Secret string `json:"secret"`
	}{
		Path: fullPath,
		Secret: img.Text,
	}

	jsonBytes, err := json.Marshal(jsonData)
	if err != nil {
		fmt.Println("Error creating JSON:", err)
		return
	}

	fmt.Println(string(jsonBytes))
}



