class LicensesController < ApplicationController
  #Не уверен, что так принято делать, но показалось, что часть логики лучше вынести в хелпер. Возможно, я не прав.
  include LicensesHelper

  def index; end

  def new
    #Нет смысла хранить таблицу с предыдущими лицензиями.
    License.destroy_all

    if params[:paid_till].empty?
      raise StandardError, 'Error: The program needs you to fill at least the "Paid till" field.'
    end
    #Инстанс-переменные, чтобы потом эти данные вывести, не возвращая к string после обработки
    @paid_till = params[:paid_till]
    @max_version = params[:max_version]
    @min_version = params[:min_version]
    create_license
    form_possible_versions
  rescue StandardError => e
    @error = e.message
    render 'index'
  end

  #Основной метод с решением. По итогу в @versions_string будет ответ
  def form_possible_versions
    @possible_versions = []
    @versions_string = ''
    license = License.last
    #Формирую хэш с данными в виде численных массивов
    data = prepare_data(license)
    form_all_possible_versions(data[:last_version])
    #Удаляю ненужные
    delete_unavailable_versions(data)
    #Если пустой массив, вывожу макс. возможную версию
    @possible_versions << data[:max_version] if @possible_versions.empty?
    #Превращаю в строку
    make_string
    render 'index'
  end

  #Черный ящик
  def get_flussonic_last_version
    '22.02'
  end

end
