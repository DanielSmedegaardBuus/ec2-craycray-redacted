# Shared stuff for root's scripts.

# Super annoying stuff when running scripts cron.d-style as root. Out environment is reset, and PATH is lost.
# So let's check for this case and remedy it. First of all, we need the path as set in /etc/environment:
. /etc/environment

# Has our ~/.profile (and thus possibly also .bashrc) been loaded? If not, do so:
[[ "$PROFILE_LOADED" = "true" ]] || . /root/.profile

# Finally our EC2 environment variables:
. /.env

shout()
{
    echo "$2" | mail -s "$1" -t $EMAIL_RECIPIENT -a FROM:"$EMAIL_SENDER"
    return 0
}
