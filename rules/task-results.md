# Task Result Handling

When returning results from tasks that will be handled by `handle_event` in Phoenix LiveView components, always use tagged tuples to make pattern matching clear and consistent.

## Rule

Return task results as tagged tuples in the format: `{:tag_name, data}`.

## Examples

### ✅ Good

```elixir
# In the task
Task.async(fn ->
  result = process_data()
  {:activity_data, result}
end)

# In the handler
def handle_event(socket, {ref, {:activity_data, data}}) when is_reference(ref) do
  # Handle the data
end
```

### ❌ Bad

```elixir
# In the task
Task.async(fn ->
  process_data()  # Returns raw data
end)

# In the handler
def handle_event(socket, {ref, data}) when is_reference(ref) do
  # Have to guess the type of data
end
```

## Benefits

1. Clear pattern matching in handler functions
2. Self-documenting code through tagged data
3. Easier to add new result types
4. Prevents accidental matching of wrong data types
5. Makes the code more maintainable and easier to debug

## Implementation

1. Always wrap task results in a tagged tuple
2. Use descriptive atom tags that indicate the type of data
3. Handle each tag explicitly in pattern matching
4. Include a catch-all case for unexpected results

## Common Tags

- `:activity_data` - For character activity data
- `:map_error` - For map-related errors
- `:event` - For general events with payloads
