# Anchors

Anchors assert positions in the string without consuming characters. They are zero-width assertions. Use them to specify where matches should occur relative to the start/end of string or lines. In multiline mode (often /m flag), ^ and $ match start/end of lines. Word boundaries \b match where a word char meets a non-word char.

## ^\tLine/String Start\tStart of line or string\tAsserts position where match must begin. In /m mode, after each newline.\tInput: 'line1\\nline2' Pattern: /^line/m Matches: 'line' (twice) - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## $\tLine/String End\tEnd of line or string\tAsserts end position. In /m, before newline at line end.\tInput: 'end1\\nend2' Pattern: /end$/m Matches: 'end' (twice) - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \\A\tString Start\tAbsolute start of string\tUnlike ^, ignores /m flag. POSIX may not support.\tInput: 'start\\nmiddle' Pattern: /\\Astart/ Matches: 'start' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \\Z\tString End\tAbsolute end of string (before optional newline)\tIgnores /m. \\z is strict end (no trailing newline).\tInput: 'end\\n' Pattern: /end\\Z/ Matches: 'end' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \\b\tWord Boundary\tBetween word and non-word char\t\\b matches where \\w meets \\W or start/end. Useful for whole words.\tInput: 'hello world' Pattern: /\\bhello\\b/ Matches: 'hello' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \\B\tNon-Word Boundary\tNot at word boundary\tOpposite of \\b. Matches inside words or between non-words.\tInput: 'hello' Pattern: /\\Bell\\B/ Matches: 'ell' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \\G\tPrevious Match End\tContinues from last match\tFor sequential matching in loops. JavaScript doesn't support.\tInput: 'abc def' Pattern: /\\G\\w+/g Matches: 'abc', 'def' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

