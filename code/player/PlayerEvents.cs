using Sandbox;

namespace BattleMages;

public static class PlayerEvents
{
    public static class Client
    {
        public const string FirstPersonArmsChanged = "firstpersonarmschanged";

        public class FirstPersonArmsChangedAttribute : EventAttribute
        {
            public FirstPersonArmsChangedAttribute() : base(FirstPersonArmsChanged) { }
        }
    }
}