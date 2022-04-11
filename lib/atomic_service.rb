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
    reset_state_vars
    @passed_initial_validation = valid?
    return @passed_initial_validation unless passed_initial_validation?
    @passed_initial_validation = true
    execute
    @successful = valid?
  end

  def call!
    reset_state_vars
    @passed_initial_validation = valid?
    raise StandardError.new(self) unless passed_initial_validation?
    @passed_initial_validation = true
    execute
    @successful = valid?
    raise StandardError.new(self) unless valid?
    @successful
  end

  def passed_initial_validation?
    @passed_initial_validation
  end  

  def before_execution?
    @passed_initial_validation.nil?
  end

  def formatted_errors
    errors.to_a
  end

  def successful?
    @successful
  end

  private

  def execute
    raise NotImplementedError, "#{self.class.name}#execute is not yet implemented"
  end

  def reset_state_vars
    @successful = false
    @passed_initial_validation = nil
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

  def defined_attributes(*filter)
    instance_variables.reduce({}) do |hash, variable_name|
      next unless filter.include?(variable_name.to_s.delete('@').to_sym) || filter.empty?

      hash[variable_name.to_s.delete('@').to_sym] = instance_variable_get(variable_name)
      hash
    end
  end

  def within_transaction(&block)
    ActiveRecord::Base.transaction do
      yield block

      raise ActiveRecord::Rollback unless valid?
    end
  end
end
