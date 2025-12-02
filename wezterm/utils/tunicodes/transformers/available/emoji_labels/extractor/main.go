package main

import (
	flag "flag"
	fmt "fmt"
	log "log"
	json "encoding/json"
	strings "strings"

	emojis "github.com/Bios-Marcel/discordemojimap/v2"
)

type cmdArgs struct {
	OutputFormat string
}

func parseArgs () (cmdArgs) {
	cmdArgs := cmdArgs{
		OutputFormat: "",
	}
	outputFormat_L := flag.String("output", "text", "Output format (json, lua)")
	outputFormat_S := flag.String("o"     , "text", "Output format (json, lua)")
	flag.Parse()
	format := *outputFormat_L
	if *outputFormat_S != "text" {
		format = *outputFormat_S
	}
	cmdArgs.OutputFormat = strings.ToLower(format)
	return cmdArgs
}

func SprintMappingsInLua (m map[string]string) (string) {
	var strBuilder strings.Builder
	strBuilder.WriteString("local Mappings = {\n")
	for key, value := range m {
		keyBytes, _ := json.Marshal(key)
		valueBytes, _ := json.Marshal(value)
		sKeyBytes := string(keyBytes)
		sValueBytes := string(valueBytes)
		s := fmt.Sprintf("\t[%v] = %v,\n", sKeyBytes, sValueBytes)
		strBuilder.WriteString(s)
	}
	strBuilder.WriteString("}\n\nreturn {\n\tMappings = Mappings,\n}\n")
	result := strBuilder.String()
	return result
}

func SprintMappingsInJson (m map[string]string) (string) {
	json, err := json.Marshal(m)
	if err != nil {
		log.Fatalf("Error marshaling map to JSON: %v", err)
	}
	result := string(json)
	return result
}

func handleOutput (m map[string]string, outputFormat string) {
	switch outputFormat {
	case "json":
		s := SprintMappingsInJson(m)
		// Assuming always stdout
		fmt.Printf(s)
	case "lua":
		s := SprintMappingsInLua(m)
		// Assuming always stdout
		fmt.Printf(s)
	default:
		log.Fatalf("Invalid output format specified")
	}
}

func main () {
	cmdArgs := parseArgs()
	m := emojis.EmojiMap
	handleOutput(m, cmdArgs.OutputFormat)
}
