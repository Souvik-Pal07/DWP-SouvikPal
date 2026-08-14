# Reflection Section

## 1. My initial hypothesis
My initial hypothesis was that the Friday application deployment was the cause of the Floor 6 login delay and missing desktop shortcuts. That was a plausible starting point because the timing lined up with the user reports on Monday morning.

## 2. Evidence that disproved it
That hypothesis did not hold when I compared the impact against the control floors. The same application was present on other floors without the issue, which showed the problem was not tied to the application deployment itself. The timing also did not match the observed login delay duration. The application removal test only produced a small improvement, not a return to normal performance.

## 3. New evidence discovered
The stronger evidence came from Intune, Event Viewer, and OneDrive logs. Those sources showed that Floor 6 had a OneDrive Known Folder Move policy assigned, that the device was processing policy during sign-in, and that OneDrive was syncing a large Desktop folder at the same time the login delay and shortcut symptoms were reported.

## 4. Correct conclusion
The correct conclusion was that the Floor 6 issues were caused by the OneDrive Known Folder Move policy, not the application deployment. The policy moved Desktop content during sign-in, which caused the slow login and the temporary disappearance of shortcuts.

## 5. Lesson learned
Do not anchor on the most visible recent change. In incident investigation, always test the scope, compare against a control group, and confirm the behavior with logs before concluding root cause. Timing alone is not evidence.
