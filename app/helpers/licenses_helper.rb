module LicensesHelper

  def self.included(base)
    base.include InstanceMethods
  end

  module InstanceMethods
    private

    def create_license
      cached_license = License.new
      cached_license.paid_till = @paid_till
      cached_license.max_version = @max_version
      cached_license.min_version = @min_version
      cached_license.save!
    end

    def prepare_data(license)
      max_version = license.max_version.split('.').map(&:to_i)
      min_version = license.min_version.split('.').map(&:to_i)
      paid_till = license.paid_till.split('.').map(&:to_i)
      paid_till.delete_at(0)
      paid_till.reverse!
      paid_till[0] = paid_till[0] % 100
      last_version = get_flussonic_last_version.split('.').map(&:to_i) # Получаю данные из черного ящика
      { max_version: max_version, min_version: min_version, paid_till: paid_till, last_version: last_version }
    end

    # Записываю в массив последние 5 версий
    def form_all_possible_versions(last_version)
      @possible_versions = [last_version]
      year = last_version[0]
      month = last_version[1]
      4.times do
        month -= 1 # Месяц
        if month.zero?
          year -= 1 # Год
          month = 12
        end
        @possible_versions << [year, month]
      end
    end

    def delete_unavailable_versions(data)
      del_with_paid(data)
      del_with_max(data)
      del_with_min(data)
    end

    def del_with_paid(data)
      @possible_versions.reverse!.delete_if do |version|
        version[0] > data[:paid_till][0] || version[0] == data[:paid_till][0] && version[1] > data[:paid_till][1]
      end
    end

    def del_with_max(data)
      unless data[:max_version].empty?
        @possible_versions.reverse!.delete_if do |version|
          (version[0] > data[:max_version][0] || version[0] == data[:max_version][0] && version[1] > data[:max_version][1])
        end
      end
    end

    def del_with_min(data)
      unless data[:min_version].empty?
        @possible_versions.reverse!.delete_if do |version|
          version[0] < data[:min_version][0] || version[0] == data[:min_version][0] && version[1] < data[:min_version][1]
        end
      end
    end

    def make_string
      #Делаю так, чтобы однозначные месяц и год выводились с ноликом
      numbers_with_zeroes
      #Формирую ответ
      possible_versions = []
      @possible_versions.map do |version|
        possible_versions << "#{version[0]}.#{version[1]}"
      end
      @versions_string = possible_versions.join(', ')
      rescue StandardError => e
      @versions_string = e.message
    end

    #Редактирует данные по типу 7->"07", 27->"27"
    def numbers_with_zeroes
      raise StandardError, 'No versions available' if @possible_versions[0].empty?
      @possible_versions.map do |version|
        version[0] = if version[0] < 10
                       "0#{version[0]}"
                     else
                       (version[0]).to_s
                     end
        version[1] = if version[1] < 10
                       "0#{version[1]}"
                     else
                       (version[1]).to_s
                     end
      end
    end
  end
end
