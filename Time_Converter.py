m = int(input("Enter number of minutes: "))
def convert_minutes(m):
    hour = m // 60
    mins = m % 60

    if hour > 0 and mins == 0:
        return f"{hour} hr" if hour == 1 else f"{h} hrs"

    if hour == 0 and mins > 0:
        return f"{mins} minute" if mins == 1 else f"{mins} minutes"

    if hour > 0 and mins > 0:
        hr_text = "hr" if hour == 1 else "hrs"
        min_text = "minute" if mins == 1 else "minutes"
        return f"{hour} {hr_text} {mins} {min_text}"

    return "0 minutes"

print(convert_minutes(m)) 
