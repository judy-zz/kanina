<% module_namespacing do -%>
class <%= class_name %>Message < Kanina::Message
  exchange ""
  routing_key ""
end
<% end -%>
