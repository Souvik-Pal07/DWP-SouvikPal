Symptom: Users logging in to POOL-FIN-01 see a black screen after sign-in. For some users it clears after about 30 seconds, while for others the session disconnects.

Cause: The verified root cause was an image-linked display/rendering regression introduced by the 02:00 POOL-FIN-01 image update. On affected hosts, dwm.exe repeatedly crashed in igdumd64.dll.

Scope: Impact was limited to POOL-FIN-01 and affected about 40% of users assigned to that pool. POOL-FIN-02 was unaffected.

Workaround: Restore service by containing new-user impact on POOL-FIN-01 and using the unaffected pool path while remediation is applied. During this incident, service was restored and users were verified logging in successfully after remediation.

Permanent fix: Apply the approved image remediation for the graphics regression on POOL-FIN-01 and return hosts to service only after validation. The incident was resolved at 10:00 with no further issues reported.

How to spot it: Look for Application Error Event 1000 showing dwm.exe faulting in igdumd64.dll (module version 31.0.101.4146, exception 0xc0000005), followed by Desktop Window Manager Event 9009 and session disconnect events. In unaffected comparison hosts, Desktop Window Manager Event 9011 appears with no matching Application Error events in the same window.