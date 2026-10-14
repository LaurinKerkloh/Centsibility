class AlertPreview < Lookbook::Preview
  def info
    render Components::Alert.new(kind: :info) { "Import started." }
  end

  def success
    render Components::Alert.new(kind: :success) { "Rule saved." }
  end

  def warning
    render Components::Alert.new(kind: :warning) { "12 transactions have no category." }
  end

  def error
    render Components::Alert.new(kind: :error) { "The file is not a DKB export." }
  end

  # @param kind select [info, success, warning, error]
  # @param message text
  def playground(kind: :info, message: "Something happened.")
    render Components::Alert.new(kind: kind.to_sym) { message }
  end
end
