class window.InteractiveWheelView extends BaseFactWheelView
  clickOpinionType: (opinion_type) ->
    fact_id = @options.fact.id

    if @model.isUserOpinion(opinion_type)
      @unsetActiveOpinionType fact_id, opinion_type
    else
      @setActiveOpinionType fact_id, opinion_type

  setActiveOpinionType: (fact_id, opinion_type) ->
    @toggleActiveOpinionType opinion_type
    $.ajax
      url: "/facts/#{fact_id}/opinion/#{opinion_type}s.json"
      type: "POST"
      success: (data) =>
        @model.updateTo data.authority, data.opinion_types
        mp_track "Factlink: Opinionate",
          factlink: @options.fact.id
          opinion: opinion_type

      error: =>
        @toggleActiveOpinionType opinion_type
        alert "Something went wrong while setting your opinion on the Factlink, please try again"

  unsetActiveOpinionType: (fact_id, opinion_type) ->
    @toggleActiveOpinionType opinion_type
    $.ajax
      type: "DELETE"
      url: "/facts/#{fact_id}/opinion.json"
      success: (data) =>
        @model.updateTo data.authority, data.opinion_types
        mp_track "Factlink: De-opinionate",
          factlink: @options.fact.id

      error: =>
        @toggleActiveOpinionType opinion_type
        alert "Something went wrong while removing your opinion on the Factlink, please try again"

  toggleActiveOpinionType: (toggle_type) ->
    new_opinion_types = {}
    for key, old_opinion_type of @model.get('opinion_types')
      new_opinion_types[old_opinion_type.type] =
        percentage: old_opinion_type.percentage
        is_user_opinion: if old_opinion_type.type == toggle_type
                           not old_opinion_type.is_user_opinion
                         else
                           false

    @model.updateTo @model.get("authority"), new_opinion_types
