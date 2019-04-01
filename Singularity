Bootstrap: docker
From: brianyee/eclip:v0.3.99

%environment
  XDG_RUNTIME_DIR=""
  export XDG_RUNTIME_DIR

%post
  mkdir /oasis 						# make the appropriate mounts for your HPC
  mkdir /projects
  mkdir /state
  mkdir /N
  rm -rf /opt/conda/lib/python2.7/site-packages/.wh.* 	# remove any dangling intermediates that docker creates
  rm /opt/conda/lib/libstdc++.so.6 			# re-link more up-to-date libstdc++
  rm /opt/conda/lib/libstdc++.so
  ln -s /opt/conda/lib/libstdc++.so.6.24 /opt/conda/lib/libstdc++.so.6
  ln -s /opt/conda/lib/libstdc++.so.6.24 /opt/conda/lib/libstdc++.so

