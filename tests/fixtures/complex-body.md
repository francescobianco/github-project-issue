# Test Issue Body

This is a **complex** body with _various_ special characters!

## Quotes and Escapes

- Double quotes: "Hello, World!"
- Single quotes: 'It's working'
- Backticks: `code here`
- Backslashes: C:\Users\test\path
- Mixed: "It's a \"quoted\" string with \\ backslashes"

## Code Block

```json
{
  "key": "value",
  "nested": {
    "array": [1, 2, 3],
    "special": "line1\nline2\ttabbed"
  }
}
```

## Special Symbols

- Arrows: -> <- => <= <-> <=>
- Math: + - * / = != < > <= >= % ^ & | ~
- Currency: $ EUR
- Punctuation: ! @ # % ^ & * ( ) [ ] { } < > ? / \ | ; : , .
- Unicode:

## Tabs and Spacing

	This line starts with a tab
    This line has 4 spaces
		Double tab here

## Edge Cases

- Empty quotes: "" ''
- Nested: "outer 'inner' outer"
- Escaped newline literal: \n \r \t
- Null-like: null NULL Null undefined
- Booleans: true false TRUE FALSE

## Final Notes

This body should test the robustness of JSON escaping!
Let's see if it works with all these "crazy" characters...

---
*End of test*
