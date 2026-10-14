class Components::Alert < Components::Base
  KINDS = {
    info: {role: "status", color: "text-info", timeout: 5000},
    success: {role: "status", color: "text-success", timeout: 5000},
    warning: {role: "alert", color: "text-warning"},
    error: {role: "alert", color: "text-danger"}
  }.freeze

  def initialize(kind: :info)
    @kind = KINDS.fetch(kind)
  end

  def view_template(&)
    div(
      role: @kind[:role],
      class: "flex items-start gap-3 rounded-md border border-border bg-surface px-4 py-3 text-sm",
      data: {controller: "alert", alert_timeout_value: @kind[:timeout]}
    ) do
      div(class: "flex-1 font-medium #{@kind[:color]}", &)
      button(
        type: "button",
        aria_label: "Dismiss",
        class: "cursor-pointer text-muted hover:text-text",
        data: {action: "alert#dismiss"}
      ) { "×" }
    end
  end
end
