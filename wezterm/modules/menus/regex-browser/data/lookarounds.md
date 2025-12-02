# Lookarounds

Lookarounds are zero-width assertions that check for patterns without consuming chars. Positive lookahead: (?=pattern). Negative lookahead: (?!pattern). Lookbehind: (?<=pattern) positive, (?<!pattern) negative. Lookbehinds may have fixed-width requirements in some engines.

## (?=)\tPositive lookahead\tAsserts followed by\tZero-width assertion.\tInput: 'ab' Pattern: /a(?=b)/ Matches: 'a' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?!)\tNegative lookahead\tAsserts not followed by\t\tInput: 'ac' Pattern: /a(?!b)/ Matches: 'a' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?<=)\tPositive lookbehind\tAsserts preceded by\tFixed width in JS.\tInput: 'ba' Pattern: /(?<=b)a/ Matches: 'a' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?<!)\tNegative lookbehind\tAsserts not preceded by\t\tInput: 'ca' Pattern: /(?<!b)a/ Matches: 'a' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

