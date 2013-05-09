class Job
  constructor: ->
    @checkJobStatus()

  checkJobStatus: ->
    jobId = $('#trends_job_id').data('job-id')
    $.poll (retry) ->
      $.getJSON "/jobs/" + jobId + "/status.json", (data)->
        if data["status"] == "complete"
          console.log 'complete'
          if data["payload"].length == 0
            $('#trends').html $('<p>Not available</p>')
          else
            $('#trends').html $('<table><thead><tr><th>Keyword</th><th>Z-score</th></tr></thead><tbody><tbody></table>')
            $.each data["payload"], (index, row)->
              $('#trends tbody').append("<tr><td>"+row['word']+"</td><td>"+row['z_score']+"</td></tr>")
        else
          console.log 'working'
          retry()

$ ->
  new Job()