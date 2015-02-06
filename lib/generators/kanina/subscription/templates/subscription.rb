<% module_namespacing do -%>
class <%= class_name %>Subscription < Kanina::Subscription
  subscribe queue: "queue_name" do |data|
    # Add the code you want to run upon receiving each message in this queue.
  end
end
<% end -%>
