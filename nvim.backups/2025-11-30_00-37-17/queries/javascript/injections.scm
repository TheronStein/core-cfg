; extends  ; Inherit defaults

;; Inject YAML into template strings
(template_string
  (string_content) @yaml
  (#set! injection.language "yaml")
)
