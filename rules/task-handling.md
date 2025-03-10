# Task Handling in LiveView Components

## Rule

When using tasks in Phoenix LiveView components, follow these guidelines:

1. Handle all task results in the main event handler (`MapEventHandler`)
2. Use tagged tuples for task results
3. Clean up task references properly
4. Handle task failures consistently

## Examples

### ✅ Good

```elixir
# In the main event handler (MapEventHandler)
def handle_event(socket, {ref, result}) when is_reference(ref) do
  Process.demonitor(ref, [:flush])
  case result do
    {:activity_data, data} ->
      socket |> push_map_event("character_activity_data", %{activity: data, loading: false})
    _ -> socket
  end
end

def handle_event(socket, {:DOWN, ref, :process, _pid, reason}) when is_reference(ref) do
  Logger.error("Task failed: #{inspect(reason)}")
  socket |> push_map_event("character_activity_data", %{activity: [], loading: false})
end

# In component handlers
def handle_ui_event("show_activity", _, socket) do
  task = Task.async(fn ->
    try do
      {:activity_data, process_data()}
    rescue
      e -> {:activity_data, []}
    end
  end)
  {:noreply, socket |> assign(:task, task)}
end
```

### ❌ Bad

```elixir
# Don't handle task results in multiple places
def handle_info({ref, result}, socket) do
  # Duplicate handling in component
end

# Don't return untagged results
def handle_ui_event("show_activity", _, socket) do
  Task.async(fn -> process_data() end)
end

# Don't forget to monitor/demonitor tasks
def handle_event(socket, {ref, result}) do
  # Missing Process.demonitor(ref, [:flush])
end
```

## Benefits

1. Centralized task result handling
2. Consistent error handling
3. No memory leaks from unmonitored tasks
4. Clear data flow through the application
5. Easier debugging and maintenance

## Implementation

1. Create tasks with proper error handling:

   ```elixir
   Task.async(fn ->
     try do
       {:tag, result}
     rescue
       e -> {:tag, default_value}
     end
   end)
   ```

2. Handle results in the main event handler:

   ```elixir
   def handle_event(socket, {ref, result}) when is_reference(ref) do
     Process.demonitor(ref, [:flush])
     # Handle result
   end
   ```

3. Handle task failures:
   ```elixir
   def handle_event(socket, {:DOWN, ref, :process, _pid, reason}) when is_reference(ref) do
     # Handle failure
   end
   ```

## Common Patterns

1. Show loading state before starting task
2. Store task reference in socket assigns
3. Use tagged tuples for all task results
4. Handle both success and failure cases
5. Clean up task references after completion
