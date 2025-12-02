# Advanced Topics

Advanced features like recursion (?R), subroutines (?&name), atomic groups (?>pattern) to prevent backtracking, balancing groups in .NET. Unicode properties \p{Property}, e.g., \p{L} for letters. Performance: avoid catastrophic backtracking with nested quantifiers.

## \p{Property}\tUnicode property\tChars with property\t\p{L} any letter, with u.\tInput: 'é' Pattern: /\p{L}/u Matches: 'é' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \P{Property}\tNegate property\tNot with property\t\P{L}\tInput: '1' Pattern: /\P{L}/u Matches: '1' - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?R)\tRecursion\tRecurse whole pattern\tFor nested.\tBalanced: /^\((?>[^()]|(?R))*\)$/ - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?&name)\tSubroutine call\tCall named group\tDefine (?<name>...) then (?&name)\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?>)\tAtomic group\tNo backtrack\tOptimizes.\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?(n)yes|no)\tConditional group\tIf n matched\t\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## (?(? =cond)yes|no)\tConditional assertion\tIf lookahead\t\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## \u{hhhhh}\tUnicode point\tUp to \u{10FFFF}\tWith u flag.\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

## balancer\tBalancing groups\t.NET specific for balanced.\t - 

**Short Description:** 

**Explanation:**


**Example:**
```

```

