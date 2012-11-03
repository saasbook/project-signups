module TeamEvaluationHelper
  def show_received_evaluations(evaluations_for_gradee_hash, students_for_group_hash, student, iteration)

    if evaluations_for_gradee_hash[student.id].present? and evaluations_for_gradee_hash[student.id][iteration.id].present?
      unique_evaluations_received = evaluations_for_gradee_hash[student.id][iteration.id].map(&:grader_id).uniq.size
      group_size = students_for_group_hash[student.group_id].size
      grader_ids = evaluations_for_gradee_hash[student.id][iteration.id].map(&:grader_id)

      s = %{<div class="title">#{unique_evaluations_received}/#{group_size - 1} evaluations received</div>}

      (students_for_group_hash[student.group_id] - [student]).each do |temp_student|
        status = grader_ids.include?(temp_student.id) ? "received" : "pending"
        s += %{<div class="#{status}">#{temp_student.full_name} (#{status})</div>}
      end
    else
      s = %{<div class="title">0 evaluations received</div>}
    end

    return s.html_safe
  end
end
