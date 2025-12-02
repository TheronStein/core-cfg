# Special Characters

Meta-characters with special meaning: . * + ? | ( ) [ ] { } ^ $ \. Escape with \ to match literally. . matches any char except newline (unless /s flag). | for alternation. In char classes, some lose meaning (e.g., * is literal inside []).

## \\ \tEscape\tMakes special literal\tTo match * use \*\tInput: '*' Pattern: /\*/ Matches: '*' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \n\tNewline\tLine feed\t\tInput: 'a\nb' Pattern: /a\nb/ Matches - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \r\tCarriage return\tCR\t\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \t\tTab\tHT\t\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \v\tVertical tab\tVT\t\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \f\tForm feed\tFF\t\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \0\tNull char\tNUL\tDo not follow with digit.\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \xhh\tHex char\tTwo hex digits\t\x41 'A'\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \uhhhh\tUnicode UTF-16\tFour hex\t\u0041 'A'\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \cX\tControl char\tA-Z for ctrl\t\cM CR\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \xxx\tOctal char\tThree octal\t\101 'A'\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

