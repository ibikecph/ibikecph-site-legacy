class DelayedJobs < ActiveRecord::Base

  attr_accessible :queue,
                  :priority,
                  :attempts,
                  :handler,
                  :last_error,
                  :run_at,
                  :locked_at,
                  :failed_at,
                  :locked_by

end
