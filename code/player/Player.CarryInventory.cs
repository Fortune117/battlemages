using System.Collections.Generic;
using Sandbox;

namespace BattleMages;

public partial class Player
{
    public const int SLOT_PRIMARY = 0;
    public const int SLOT_SECONDARY = 1;
    public const int SLOT_PISTOL = 2;
    public const int SLOT_MELEE = 3;
    public const int SLOT_UTIL = 4;
    public const int SLOT_BOLT = 5;
    public const int SLOT_EMPTY = 9; //this slot is always, reliably, empty!
    public const int SLOT_GRENADE = 10;
    
    [Net] private IDictionary<int,Carriable> CarrySlots { get; set; } = new Dictionary<int, Carriable>();
    [Net, Predicted] private int ActiveSlot { get; set; } = SLOT_EMPTY;
    [Net, Predicted] private int PreviousSlot { get; set; } = SLOT_EMPTY;
    [Net, Predicted] private bool IsSwitchingSlot { get; set; } = false;
    [Net, Predicted] private int QueuedSlot { get; set; }
    [Net, Predicted] private TimeUntil TimeUntilSwitchFinished { get; set; } = 0;

    private Carriable ActiveCarry => GetActiveCarry();
    
    
    public Carriable GetActiveCarry()
    {
        CarrySlots.TryGetValue(ActiveSlot, out var active);
        return active;
    }
    
    public Carriable GetCarriableAtSlot(int slot)
    {
        CarrySlots.TryGetValue(slot, out var value);
        return value;
    }
    
    public virtual bool SetActive( int slot )
    {
        var ent = GetCarriableAtSlot(slot);

        PreviousSlot = ActiveSlot;
        ActiveSlot = slot;
        ActiveChild = ent;
        
        return true;
    }

    public bool AddToSlot(Carriable carriable, int slot, bool makeActive, bool fastActive = false)
    {
        Game.AssertServer();

        if ( !carriable.IsValid() )
            return false;

        if ( !carriable.CanCarry( this ) )
            return false;
        
        carriable.Parent = this;
        CarrySlots[slot] = carriable;
        
        carriable.OnCarryStart( this );

        if (!makeActive) 
            return true;
        
        if (fastActive)
            SetActive(slot);
        else
            SwitchToSlot(slot);

        return true;
    }

    public Carriable DropActive()
    {
        var active = GetActiveCarry();
        if (!active.IsValid())
            return null;

        //OnDroppedWeapon(active);
        
        active.Parent = null;
        
        active.OnCarryDrop( this );

        active.PhysicsGroup?.ApplyImpulse( Velocity + AimRay.Forward * 500.0f + Vector3.Up * 100.0f, true );
        active.PhysicsGroup?.ApplyAngularImpulse( Vector3.Random * 100.0f, true );

        CarrySlots[ActiveSlot] = null;
        ActiveChild = null;
        
        return active;
    }

    public void ResetCarryInventory()
    {
        foreach (var value in CarrySlots.Values)
        {
            if (value.IsValid())
                value.Delete();
        }

        ActiveSlot = 0;
        PreviousSlot = 0;
        ActiveChild = null;
    }

    /// <summary>
    /// Swaps thee player to their last used gun, and if that's unavailable to their highest priority gun.
    /// </summary>
    public void SwitchToSmartActive()
    {
        if (GetCarriableAtSlot(PreviousSlot).IsValid())
        {
            SwitchToSlot(PreviousSlot);
            return;
        }
        
        if (GetCarriableAtSlot(SLOT_PRIMARY).IsValid())
        {
            SwitchToSlot(SLOT_PRIMARY);
            return;
        }

        if (GetCarriableAtSlot(SLOT_SECONDARY).IsValid())
        {
             SwitchToSlot(SLOT_SECONDARY);
             return;
        }
        
        if (GetCarriableAtSlot(SLOT_PISTOL).IsValid())
        {
            SwitchToSlot(SLOT_PISTOL);
            return;
        }
        
        if (GetCarriableAtSlot(SLOT_MELEE).IsValid())
        {
            SwitchToSlot(SLOT_MELEE);
            return;
        }
    }
    
    private void SwitchToSlot(int newSlot)
    {
        if (IsSwitchingSlot)
            return;

        if (ActiveCarry is ICarryItem carryItem && !carryItem.CanHolster() )
        {
            Log.Info(ActiveCarry);
            return;
        }
        
        if (newSlot == ActiveSlot && ActiveChild.IsValid())
        {
            SwitchToSlot(SLOT_EMPTY); //just swap to empty slot
            return;
        }

        if (ActiveCarry == null)
        {
            SetActive(newSlot);
            return;
        }
        
        TimeUntilSwitchFinished = 0f;
        IsSwitchingSlot = true;
        QueuedSlot = newSlot;

        Holster();
    }

    private void Holster()
    {
        if (ActiveChild is not ICarryItem swapTime) 
            return;
        
        swapTime.Holster();
        TimeUntilSwitchFinished = swapTime.HolsterDelay;
    }
    
    private void SimulateCarryInventory(IClient client)
    {
        if (Prediction.FirstTime)
        {
            if (IsSwitchingSlot)
            {
                if (TimeUntilSwitchFinished < 0)
                {
                    SetActive(QueuedSlot);
                    IsSwitchingSlot = false;
                }
                else
                {
                    return;
                }
            }

            /*if (Input.Pressed(InputButton.Slot1)) SwitchToSlot( 0 );
            if (Input.Pressed(InputButton.Slot2)) SwitchToSlot( 1 );
            if (Input.Pressed(InputButton.Slot3)) SwitchToSlot( 2 );
            if (Input.Pressed(InputButton.Slot4)) SwitchToSlot( 3 );
            if (Input.Pressed(InputButton.Slot5)) SwitchToSlot( 4 );
            if (Input.Pressed(InputButton.Slot6)) SwitchToSlot( 5 );
            if (Input.Pressed(InputButton.Slot7)) SwitchToSlot( 6 );*/
        }
    }

    public void AddStartingItems()
    {
        AddToSlot(new Powers(), SLOT_PRIMARY, false);
        SwitchToSmartActive();
    }
}