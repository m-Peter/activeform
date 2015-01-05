<% module_namespacing do -%>
class <%= class_name %>Form < ActiveForm::Base
  <% if attributes.present? %>
    attributes <%= attributes.map {|a| ":#{a.name}" }.join(", ") %>
  <% else %>
  # attributes :name, :email
  <% end %>
end
<% end -%>
