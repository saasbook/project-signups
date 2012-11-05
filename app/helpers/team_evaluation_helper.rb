module TeamEvaluationHelper
  def show_received_evaluations(evaluations_for_gradee_hash, students_for_group_hash, all_evaluations_received, student, iteration)

    if evaluations_for_gradee_hash[student.id].present? and evaluations_for_gradee_hash[student.id][iteration.id].present?
      unique_evaluations_received = evaluations_for_gradee_hash[student.id][iteration.id].map(&:grader_id).uniq.size
      group_size = students_for_group_hash[student.group_id].size
      grader_ids = evaluations_for_gradee_hash[student.id][iteration.id].map(&:grader_id)

      s = %{<div class="title">#{unique_evaluations_received}/#{group_size} evaluations received</div>}

      statuses = []
      students_for_group_hash[student.group_id].each do |temp_student|
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

  def team_evaluation_table(group_id, indexed_evaluations, students)
    s = %{}
    indices = indexed_evaluations.keys
    student_ids = students.map(&:id)
    student_for_id_hash = students.index_by {|student| student.id}
    lowest_student_id = student_ids.min
    highest_student_id = student_ids.max

    s += %{ <section class="group-evaluations-wrapper">
              <div class="axis grader-axis">Evaluators</div>
              <div class="axis gradee-axis">Recipients</div>}

    s += %{<table class="group-#{group_id}-evaluations">}
    (lowest_student_id-1..highest_student_id).each do |gradee_id|
      s += %{<tr>}
      (lowest_student_id-1..highest_student_id).each do |grader_id|
        if !student_ids.include?(gradee_id)
          # first row, output grader name from grader_id
          if !student_ids.include?(grader_id)
            # first col
            s += %{<td class="definition">
                      <h2 class="group-label">Group #{group_id}</h2>
                  </td>}
          else
            s += %{<td class="grader-label">#{student_for_id_hash[grader_id].full_name}</td>}
          end
        else
          if !student_ids.include?(grader_id)
            # first column, output gradee name
            s += %{<td class="gradee-label">#{student_for_id_hash[gradee_id].full_name}</td>}
          else
            evaluation = indexed_evaluations[[gradee_id, grader_id]]
            # it's possible no evaluation is here
            s += %{<td class="evaluation" data-evaluation-id="#{evaluation.present? ? evaluation.id : "0"}">}
            if evaluation.present?
              s += %{<div class="score-container">
                      <div class="score-wrapper">
                        <span class="label">Score:</span> 
                        <span class="score-value">#{evaluation.score}</span>
                        #{image_tag "edit.png", :class => "icon-edit-score inactive" }
                      </div>
                      <div class="edit-score-wrapper inactive">
                        <span class="label">Score:</span> 
                        #{text_field_tag :"edit-evaluation-#{evaluation.id}-score-input", evaluation.score, :class => "edit-score-input"}
                      </div>
                    </div>
                    <div class="comment">
                      <span class="label">Comment:</span> 
                      <span class="comment-text">#{sanitize(evaluation.comment)}</span>
                    </div>}
            else
              s += %{<div class="no-evaluation">Missing</div>}
            end
            s += %{</td>}
          end
        end
      end
    end
    s += %{</table>}
    s += %{</section>}
    return s.html_safe
  end
end
