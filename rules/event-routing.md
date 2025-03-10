# Event Routing in LiveView Components

## Rule

Event handlers should follow a clear routing hierarchy:

1. Main event handler (`MapEventHandler`) acts as a router only
2. Domain-specific handlers handle their own events
3. All events (UI, server, task results) should be routed through the appropriate handler

## Examples

### ✅ Good

```elixir
# In the main event handler (MapEventHandler)
@map_activity_events [:character_activity, :character_activity_data]

def handle_event(socket, %{event: event_name} = event)
    when event_name in @map_activity_events,
    do: MapActivityEventHandler.handle_server_event(event, socket)

# For task results
def handle_event(socket, {ref, result}) when is_reference(ref) do
  Process.demonitor(ref, [:flush])
  case result do
    {:activity_data, data} ->
      MapActivityEventHandler.handle_server_event(
        %{event: :character_activity_data, payload: data},
        socket
      )
    _ -> socket
  end
end

# In the specific handler (MapActivityEventHandler)
def handle_server_event(%{event: :character_activity_data, payload: data}, socket) do
  socket |> push_map_event("character_activity_data", %{activity: data, loading: false})
end
```

### ❌ Bad

```elixir
# Don't handle domain logic in the router
def handle_event(socket, {ref, result}) when is_reference(ref) do
  case result do
    {:activity_data, data} ->
      socket |> push_map_event("character_activity_data", %{activity: data})
  end
end

# Don't mix routing and handling
def handle_event(socket, event) do
  case event.type do
    :activity -> handle_activity(socket, event)
    :system -> SystemHandler.handle_event(event, socket)
  end
end
```

## Benefits

1. Clear separation of concerns
2. Consistent event handling patterns
3. Easier to maintain and extend
4. Better testability
5. Domain logic stays with domain handlers

## Implementation

1. Define event types in the router:

   ```elixir
   @map_activity_events [:character_activity, :character_activity_data]
   @map_system_events [:add_system, :update_system]
   ```

2. Route events based on type:

   ```elixir
   def handle_event(socket, %{event: event_name} = event)
       when event_name in @map_activity_events,
       do: MapActivityEventHandler.handle_server_event(event, socket)
   ```

3. Transform task results into proper events:
   ```elixir
   def handle_event(socket, {ref, {:activity_data, data}}) when is_reference(ref) do
     MapActivityEventHandler.handle_server_event(
       %{event: :character_activity_data, payload: data},
       socket
     )
   end
   ```

## Common Patterns

1. Group related events in module attributes
2. Use pattern matching for routing
3. Transform task results into standard event format
4. Keep domain logic in specific handlers
5. Route all events through the main handler
