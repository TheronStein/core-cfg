# Basics

Fundamental concepts and syntax of regular expressions. Regex (Regular Expressions) are patterns used to match character combinations in strings. They are supported in most programming languages and tools like grep, sed, awk, Python (re module), JavaScript, etc. Regex engines vary slightly (e.g., PCRE vs POSIX), but core concepts are similar. Always test patterns as behavior can differ across flavors (e.g., Java vs Perl).

## .\tAny Character\tMatches any single character except newline\tThe dot . is a wildcard for any char (byte in some engines). With /s flag, it matches newlines too. In Unicode, it matches code points. Pitfall: Doesn't match line breaks in all contexts.\tInput: 'abc\\n123' Pattern: /./g Matches: a,b,c,1,2,3 (skips \\n without /s) - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## ^\tStart of String\tAsserts position at start of string\t^ matches only at the beginning. In multiline /m, at start of each line. Useful for exact prefix matching.\tInput: 'hello world' Pattern: /^hello/ Matches: 'hello' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## $\tEnd of String\tAsserts position at end of string\t$ matches only at the end. In /m, at end of each line before newline. Trailing newlines may affect it.\tInput: 'hello world' Pattern: /world$/ Matches: 'world' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## |\tAlternation\tMatches either left or right pattern\t| acts like logical OR. Groups with () for precedence. Greedy: tries left first.\tInput: 'cat dog' Pattern: /cat|dog/ Matches: 'cat', 'dog' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## ()\tGrouping\tGroups patterns as a unit\t() captures the match for backrefs. Also for applying quantifiers to subpatterns.\tInput: 'abc abc' Pattern: /(abc) \\1/ Matches: 'abc abc' (backref to group 1) - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## []\tCharacter Set\tMatches any char in the set\t[abc] matches a or b or c. Ranges [a-z]. ^ negates: [^a-z] non-lowercase letters.\tInput: 'apple' Pattern: /[aeiou]/g Matches: a,e - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

