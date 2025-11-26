# Character Classes

Character classes match any one character from a set. Use [ ] to define. Negate with ^ inside. Ranges like a-z. Shorthand: \d (digit), \w (word char: alphanumeric + _), \s (whitespace). Negated: \D, \W, \S. In Unicode mode, these can match more chars. POSIX classes like [:alpha:] for alphabetic chars.

## \d\tDigit\tMatches any digit [0-9]\t\D negate.\tInput: 'a1b' Pattern: /\d/g Matches: '1' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \w\tWord character\tMatches alphanumeric or _ [A-Za-z0-9_]\t\W negate.\tInput: 'a_b' Pattern: /\w/g Matches: 'a','_','b' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \s\tWhitespace\tMatches space, tab, newline etc.\t\S negate.\tInput: 'a b' Pattern: /\s/ Matches: ' ' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \D\tNon-digit\tMatches anything but digit\tOpposite of \d.\tInput: '1a' Pattern: /\D/ Matches: 'a' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \W\tNon-word\tMatches anything but word char\tOpposite of \w.\tInput: 'a!' Pattern: /\W/ Matches: '!' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \S\tNon-whitespace\tMatches anything but whitespace\tOpposite of \s.\tInput: ' a ' Pattern: /\S/ Matches: 'a' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## [abc]\tCharacter class\tAny of a b c\tRanges [a-c].\tInput: 'abd' Pattern: /[a-c]/g Matches: 'a','b' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## [^abc]\tNegated class\tNot a b c\t[^a-c].\tInput: 'abd' Pattern: /[^a-c]/ Matches: 'd' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## [:alpha:]\tPOSIX alpha\tAlphabetic chars\tInside [].\tInput: 'a1' Pattern: /[[:alpha:]]/ Matches: 'a' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## [:digit:]\tPOSIX digit\tDigits\t[[:digit:]].\tInput: 'a1' Pattern: /[[:digit:]]/ Matches: '1' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## [:alnum:]\tPOSIX alnum\tAlphanumeric\t[[:alnum:]].\tInput: 'a1_' Pattern: /[[:alnum:]]/g Matches: 'a','1' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \p{L}\tUnicode letter\tLetters in Unicode\tWith u flag.\tInput: 'é1' Pattern: /\p{L}/u Matches: 'é' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

