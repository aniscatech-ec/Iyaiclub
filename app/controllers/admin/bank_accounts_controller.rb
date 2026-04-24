module Admin
  class BankAccountsController < ApplicationController
    layout "dashboard"
    before_action :authenticate_user!
    before_action :authenticate_admin!
    before_action :set_bank_account, only: [:edit, :update, :destroy, :toggle_active]

    def index
      @bank_accounts = BankAccount.ordered
    end

    def new
      @bank_account = BankAccount.new
    end

    def create
      @bank_account = BankAccount.new(bank_account_params)
      if @bank_account.save
        redirect_to admin_bank_accounts_path, notice: "Cuenta bancaria agregada correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @bank_account.update(bank_account_params)
        redirect_to admin_bank_accounts_path, notice: "Cuenta bancaria actualizada."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @bank_account.destroy
      redirect_to admin_bank_accounts_path, notice: "Cuenta bancaria eliminada."
    end

    def toggle_active
      @bank_account.update!(active: !@bank_account.active)
      redirect_to admin_bank_accounts_path,
                  notice: "Cuenta #{@bank_account.active? ? 'activada' : 'desactivada'}."
    end

    private

    def set_bank_account
      @bank_account = BankAccount.find(params[:id])
    end

    def bank_account_params
      params.require(:bank_account).permit(
        :institution, :account_type, :account_number,
        :owner_name, :identifier, :identifier_type,
        :active, :notes
      )
    end
  end
end
