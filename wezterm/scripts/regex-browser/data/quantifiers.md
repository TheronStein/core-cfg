# Quantifiers

Quantifiers specify how many times a pattern or group should match. They can be greedy (match as much as possible) or lazy (match as little as possible, add ? after quantifier). Greedy: *, +, {n,}. Lazy: *?, +?, {n,]?. Possessive quantifiers (e.g., *+) prevent backtracking for optimization in some engines.

## *\tZero or more\tMatches 0 or more of previous\tGreedy by default. *? lazy, *+ possessive (in PCRE).\tInput: 'aaab' Pattern: /a*/ Matches: 'aaa' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## +\tOne or more\tMatches 1 or more of previous\t+? lazy, ++ possessive.\tInput: 'aaab' Pattern: /a+/ Matches: 'aaa' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## ?\tZero or one\tMatches 0 or 1 of previous\t?? lazy.\tInput: 'ab' Pattern: /a?/ Matches: 'a' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## {n}\tExactly n\tMatches exactly n of previous\tFixed count.\tInput: 'aaa' Pattern: /a{3}/ Matches: 'aaa' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## {n,}\tAt least n\tMatches n or more of previous\t{n,}? lazy.\tInput: 'aaaa' Pattern: /a{2,}/ Matches: 'aaaa' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## {n,m}\tBetween n and m\tMatches between n and m of previous\t{n,m}? lazy.\tInput: 'aaa' Pattern: /a{2,4}/ Matches: 'aaa' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## *?\tLazy zero or more\tMatches 0 or more, as few as possible\tAdd ? to make lazy.\tInput: 'aaab aaa' Pattern: /a*?a/ Matches minimal - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## +?\tLazy one or more\tMatches 1 or more, as few as possible\tLazy version.\tInput: 'aaab' Pattern: /a+?b/ Matches 'aaab' minimal a - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## *+\tPossessive zero or more\tMatches 0 or more, no backtrack\tPossessive, optimizes in some engines.\tInput: 'aaa" ' Pattern: /".*+"/ Matches fail if needed - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

