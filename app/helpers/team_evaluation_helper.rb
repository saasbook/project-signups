module TeamEvaluationHelper
  def show_received_evaluations(evaluations_for_gradee_hash, students_for_group_hash, all_evaluations_received, student, iteration)

    if evaluations_for_gradee_hash[student.id].present? and evaluations_for_gradee_hash[student.id][iteration.id].present?
      unique_evaluations_received = evaluations_for_gradee_hash[student.id][iteration.id].map(&:grader_id).uniq.size
      group_size = students_for_group_hash[student.group_id].size
      grader_ids = evaluations_for_gradee_hash[student.id][iteration.id].map(&:grader_id)

      s = %{<div class="title">#{unique_evaluations_received}/#{group_size - 1} evaluations received</div>}

      statuses = []
      (students_for_group_hash[student.group_id] - [student]).each do |temp_student|
        if !grader_ids.include?(temp_student.id)
          status = "none"
          statuses.push(status)
        else
          evaluations_for_gradee_hash[student.id][iteration.id].each do |evaluation|
            # associate grader with evaluation's delivery status
            if evaluation.grader_id == temp_student.id
              if evaluation.delivered == true
                status = "delivered"
              else
                status = "created"
              end
              statuses.push(status)
            end
          end
        end
        s += %{<div class="#{status}">#{temp_student.full_name} (<span class="status">#{status}</span>)</div>}
      end

      if iteration.emails_delivered == true and statuses.uniq.join() != "delivered" and all_evaluations_received == true
        # redeliver if we have already delivered, we have not already delivered, and everyones evaluations are ready
        redelivery_option = true
      else
        redelivery_option = false
      end

      if redelivery_option == true
        s += link_to "Resend Group Evaluations", "#", :class => "btn email-group-evaluations-btn", :"data-group-id" => student.group_id, :"data-iteration-id" => iteration.id, :"data-iteration-name" => iteration.name
      end
    else
      s = %{<div class="title">0 evaluations received</div>}
    end

    return s.html_safe
  end
end
