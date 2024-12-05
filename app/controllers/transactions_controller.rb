class TransactionsController < ApplicationController
  before_action :init_new_transaction, only: %i[new new_large new_extra_large]

  def index
    # I think includes will work faster here than joins as managers will be much less people than transactions
    # If the database is large enough SQL EXPLAIN ANALYSE can be used to check the performance and compare the results
    @transactions = Transaction.includes(:manager).all
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def new
    validate_transaction_type
    render "new_#{params[:type]}"
  end

  def create
    @transaction = Transaction.new(permitted_params)

    @transaction.manager = Manager.order('RANDOM()').first if params[:type] == 'extra'

    if @transaction.save
      redirect_to @transaction
    else
      validate_transaction_type
      render "new_#{params[:type]}"
    end
  end

  private

  def permitted_params
    permitted = %i[from_currency from_amount to_currency]
    permitted += %i[first_name last_name] if %w[large extra].include?(params[:type])

    params.require(:transaction).permit(permitted)
  end

  def init_new_transaction
    @transaction = Transaction.new
  end

  def validate_transaction_type
    raise ArgumentError, 'Invalid transaction type' unless %w[small large extra].include?(params[:type])
  end
end
