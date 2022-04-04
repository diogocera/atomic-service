require 'active_model'
require 'after_commit_everywhere'

class AtomicService
  include ActiveModel::Model
  include AfterCommitEverywhere

  def self.call(*args)
    instance = new(*args)
    instance.call
    instance
  end

  def call
    return false unless valid?
    @passed_initial_validation = true

    execute
    valid?
  end

  def call!
    raise Errors::Validation.new(self) unless valid?
    @passed_initial_validation = true
    execute
    raise Errors::Execution.new(self) unless valid?
  end

  def passed_initial_validation?
    @passed_initial_validation
  end

  def formatted_errors
    errors.to_a
  end

  private

  def execute
    raise NotImplementedError, "#{self.class.name}#execute is not yet implemented"
  end

  def valid?(model = nil)
    return false unless errors.none? && super

    clone_errors(model) if model

    errors.none?
  end

  def clone_errors(model)
    return unless model
    model.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end

  def changing_attributes(filter)
    attrs = {}
    instance_variables.each do |variable_name|
      if filter.include?(variable_name.to_s.gsub('@', '').to_sym)
        attrs[variable_name.to_s.gsub('@', '')] = instance_variable_get(variable_name)
      end
    end
    attrs
  end

  def within_transaction(&block)
    ActiveRecord::Base.transaction do
      yield block

      raise ActiveRecord::Rollback unless valid?
    end
  end
end