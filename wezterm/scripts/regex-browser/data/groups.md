# Groups and Capturing

Groups allow treating multiple chars as a unit. () for capturing groups (store matched text for backreferences or extraction). Non-capturing: (?:). Named groups: (?P<name>) or (?<name>) depending on flavor. Backreferences: \1, \2, or ${name}. Conditionals: (?(condition)yes|no).

## ()\tCapturing group\tGroups and captures the match\tFor backrefs \1.\tInput: 'abc abc' Pattern: /(abc) \1/ Matches: 'abc abc' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?:)\tNon-capturing group\tGroups without capturing\tNo backref, better performance.\tInput: 'abc' Pattern: /(?:ab)c/ Matches: 'abc' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?<name>)\tNamed capturing group\tCaptures with name\tBackref \k<name>.\tInput: 'abc' Pattern: /(?<group>ab)c/ Matches: 'abc', group='ab' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \n\tBackreference\tReferences nth group\t\1 for first.\tInput: 'aa' Pattern: /(a)\1/ Matches: 'aa' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \k<name>\tNamed backref\tReferences named group\tDepending on flavor.\tInput: 'aa' Pattern: /(?<char>a)\k<char>/ Matches: 'aa' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?(n)yes|no)\tConditional\tIf group n matched, yes else no\tCondition on group.\tInput: 'ab' Pattern: /(a)?(?(1)b|c)/ Matches: 'ab' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?(?=cond)yes|no)\tLookaround conditional\tIf assertion true, yes else no\tCondition on lookahead.\tInput: 'ab' Pattern: /a(?(?=b)b|c)/ Matches: 'ab' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?#comment)\tComment\tInline comment\tWith x flag, ignored.\tInput: 'a' Pattern: /a(?#test)/x Matches: 'a' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?>\tAtomic group\tNon-backtracking group\tPossessive, no backtrack.\tInput: 'aaab' Pattern: /(?>a+)ab/ No match - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?R)\tRecursion\tRecurse the pattern\tFor nested structures.\tBalanced parens: /^\((?>[^()]+|(?R))*\)$/ - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

