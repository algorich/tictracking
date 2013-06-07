class TasksController < ApplicationController
  before_filter :authenticate_user!

  def create
    @task = Task.new(params[:task])

    if @task.save
      redirect_to project_path @task.project_id, notice: 'Criado com sucesso'
    else
      flash[:error] = 'Não pode ser criado'
      redirect_to project_path @task.project_id
    end
  end
end