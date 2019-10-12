package envy

func LoadConfig(path string) (map[string]string, error) {
	config := make(map[string]string)
	err := ParseFile(path, func(mode Mode, pt1 string, pt2 string) {
		switch mode {
		case Mode_Value:
			config[pt1] = pt2
		case Mode_Secured_Value:
			config[pt1] = DecryptSecuredValue(pt2)
		}
	})

	return config, err
}
