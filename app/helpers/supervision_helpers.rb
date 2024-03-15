# frozen_string_literal: true

# app/helpers/supervision_helpers.rb
module SupervisionHelper
  def fetch_available_dates(supervision_params, supervision_metadata)
    time_table_params = supervision_params.slice(:course_id, :branch_id, :examination_name, :academic_year,
                                                 :examination_type, :examination_time)
    ExamTimeTable.where(time_table_params)
                 .pluck(:examination_date)
                 .uniq
                 .map { |date| date.strftime('%Y-%m-%d') }
                 .reject { |x| supervision_metadata.keys.include?(x) }
  end

  def generate_metadata(supervision, dates, number_of_supervisions, block_extra_configs) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    metadata = {}
    dates_to_assign = dates&.sample(number_of_supervisions)

    if dates_to_assign.present?
      dates_to_assign.each do |date|
        block_extra_config = block_extra_configs.find_by(date:)

        downcase_user_type = supervision.user_type.downcase
        user_type = downcase_user_type == 'junior' ? 'Junior' : 'Senior'

        no_of_blocks = find_number_of_blocks(downcase_user_type, block_extra_config)

        supervisions = Supervision.where(user_type:).where('metadata LIKE ?', "%#{date}%")

        if supervisions.count < no_of_blocks || supervisions.pluck(:id).include?(supervision.id)
          metadata[date] = true
        else
          dates_to_assign = dates.sample(number_of_supervisions)
        end
      end
    end

    metadata
  end

  def find_number_of_blocks(downcase_user_type, block_extra_config)
    if downcase_user_type == 'junior'
      block_extra_config.number_of_supervisions + block_extra_config.number_of_extra_jr_supervision
    else
      block_extra_config.number_of_extra_sr_supervision
    end
  end
end
