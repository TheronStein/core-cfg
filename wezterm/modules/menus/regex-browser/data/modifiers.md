# Modifiers and Flags

Flags change regex behavior globally. Common: i (case-insensitive), m (multiline: ^/$ per line), s (dotall: . matches newline), g (global: find all matches), x (extended: ignore whitespace in pattern). Unicode u flag for full Unicode matching. Flags are often set outside the pattern, e.g., /pattern/im.

## ii\tCase insensitive\tIgnore case\t/abc/i Matches 'AbC'\tGlobal flag outside pattern. - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## g\tGlobal\tFind all matches\t/ a /g All 'a'\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## m\tMultiline\t^ $ match line start/end\t/ ^a /m 'a' after newline\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## s\tDotall\t. matches newline\t/ a.b /s 'a\nb'\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## u\tUnicode\tFull Unicode support\t/ \p{L} /u Matches letters\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## y\tSticky\tMatch from lastIndex\tJS, / a /y\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## x\tExtended\tIgnore whitespace, allow comments\t/ a b #comment /x 'ab'\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## U\tUngreedy\tQuantifiers lazy by default\tPCRE, / a+ /U Greedy to lazy\t\tCase insensitive\tIgnore case\t/abc/i Matches 'AbC'\tGlobal flag outside pattern. - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## g\tGlobal\tFind all matches\t/ a /g All 'a'\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## m\tMultiline\t^ $ match line start/end\t/ ^a /m 'a' after newline\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## s\tDotall\t. matches newline\t/ a.b /s 'a\nb'\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## u\tUnicode\tFull Unicode support\t/ \p{L} /u Matches letters\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## y\tSticky\tMatch from lastIndex\tJS, / a /y\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## x\tExtended\tIgnore whitespace, allow comments\t/ a b #comment /x 'ab'\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## U\tUngreedy\tQuantifiers lazy by default\tPCRE, / a+ /U Greedy to lazy\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

