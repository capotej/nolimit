{application,nolimit,
             [{description,"nolimit"},
              {vsn,"1"},
              {modules,[nolimit,nolimit_app,nolimit_resource,nolimit_sup]},
              {registered,[]},
              {applications,[kernel,stdlib,inets,crypto,mochiweb,webmachine]},
              {mod,{nolimit_app,[]}},
              {env,[]}]}.
