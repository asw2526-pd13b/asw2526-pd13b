module ApplicationHelper
  def vote_value_for(votable)
    return 0 unless respond_to?(:user_signed_in?) && user_signed_in?
    return 0 unless respond_to?(:current_user) && current_user

    vote = nil

    if votable.respond_to?(:votes)
      vote = votable.votes.find_by(user_id: current_user.id) rescue nil
    end

    if vote.nil? && current_user.respond_to?(:votes)
      vote = current_user.votes.find_by(votable: votable) rescue nil
      vote ||= current_user.votes.find_by(votable_type: votable.class.name, votable_id: votable.id) rescue nil
    end

    return 0 unless vote

    val =
      if vote.respond_to?(:value)
        vote.value
      elsif vote.respond_to?(:vote)
        vote.vote
      elsif vote.respond_to?(:direction)
        vote.direction
      else
        0
      end

    val.to_i
  end

end
