settings {
    "main": {
        "description": "A framework for (somewhat) easily creating a nice 2D menu.\nSee workshop.code/E7TAC for explaination on how to utilize this code.\nUse overpy it is awesome!\nSee https://github.com/a-bella-ciao/OW2-Workshop-Menu-API for the overpy file used to create this code. ",
        "modeName": "2D menu framework"
    },
    "gamemodes": {
        "skirmish": {
            "enabledMaps": [
                "workshopChamber"
            ]
        }
    }
}

# Global Variables
## Global Menu Variables
### Colors
globalvar default_menu_label_color
globalvar default_menu_off_index_color
globalvar default_menu_on_index_color
globalvar default_cycle_toggle_colors
globalvar active_color_list

## Demonstartion Variables
globalvar demo_var_menu_text_array

# Player Variables
## Player Menu Variables
### General Menu Variables
playervar menu_visable
playervar menu_index
playervar menu_input
playervar menu_max_pos
playervar menu_do_off_actions
### Menu Label Variables
playervar menu_label_size
playervar menu_label
playervar menu_label_color
### Menu Option Variables
playervar menu_opt_size
playervar menu_off_opt_title
playervar menu_on_opt_title
playervar menu_opt_var
playervar menu_opt_status
playervar menu_off_opt_color
playervar menu_on_opt_color
### Bar Variables
playervar bar_title
playervar bar_var
playervar bar_color
### Submenu Variables
playervar submenu_start_index
playervar submenu_index
playervar sub_size
## Demonstation Variables
playervar demo_cycle_menu_index
playervar demo_cycle_menu_status

#Subroutine Names
## Menu Defaults
subroutine default_menu_variables
## Menu Toggle actions
subroutine enable_player_input
subroutine menu_off_actions
## Menu Prompt
subroutine create_settings_prompt
## Menu Labels
subroutine increment_for_menu_label
subroutine new_menu_label_header
subroutine new_menu_label_subtext
## Menu Items
subroutine increment_for_menu_item
subroutine new_menu_item_selection
subroutine new_menu_item_toggle
subroutine new_menu_item_cycle
subroutine new_menu_item_cycle_bar
## Submenu
subroutine increment_for_submenu_item
## Menu Actions
subroutine menu_action_selection
subroutine menu_action_toggle
subroutine menu_action_cycle
subroutine menu_action_cycle_bar
subroutine menu_action_open_submenu
subroutine menu_action_close_submenu


rule "Rules with (O - ) should be copied, rules with (X - ) are just used to demonstrate how to use the menu":

    smallMessage(hostPlayer, "hi")


rule "Initialize Global Menu Variables (O - copy this, set the colors to the colors you want your menu to be by default you can also change the selection color per menu item in the generate rule)":

    # Here we define what the default colors are for our menu.
    # In this case our labels will be white.
    default_menu_label_color = Color.WHITE
    # When the cursor is not on an item on the menu the text will be white.
    default_menu_off_index_color = Color.WHITE
    # When the cursor is on an item on the menu, the text will be yellow.
    default_menu_on_index_color = Color.YELLOW


rule "Menu Controls: Toggle Menu with Interact (O - copy this)":
    @Event eachPlayer
    @Team 1
    # Change this condition to whatever button(s) you want to trigger the main menu. 
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    
    # A toggle for the menu_visible flag
    if eventPlayer.menu_visable == true:
        eventPlayer.menu_visable = false
    else:
        eventPlayer.menu_visable = true
        # If we are opening a different menu other than the last one we were on, we reset the menu_index so that it is at the start of this menu.
        if eventPlayer.submenu_index != 0:
            eventPlayer.submenu_index = 0
            eventPlayer.menu_index = eventPlayer.submenu_start_index[eventPlayer.submenu_index]
        
        

rule "Menu Controls: Toggle On Setup (O - copy this)":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.menu_visable == true

    # Disable player inputs and set the movement speed to zero. 
    # If you'd liked to enable certain in-game inputs while the player is in the menu remove the relavent disallow action.
    # If you remove the movement speed action the player will be able to move freely which looks awkward since we are using their movements to navigate the menu.
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.JUMP)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.ULTIMATE)
    eventPlayer.setMoveSpeed(0)


rule "Menu Controls: Toggle Off Setup (O - copy this)":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.menu_visable == false

    # Enable Player inputs
    enable_player_input()
    # If you need to perform actions only after the menu is closed, and not as it is being configured, modify this subroutine to do so. 
    # Good for preventing the player from triggering high server load actions when they are just cycling though options.
    if eventPlayer.menu_do_off_actions == true:
        menu_off_actions()


rule "Menu Controls: Up Scroll (O - copy this)":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.menu_visable == true
    # We use the player's movement keys to navigate the menu.
    # If you'd like to use a button input instead, change this condition.
    @Condition eventPlayer.getThrottle() == Vector.FORWARD
    
    # If the menu index is equal to the start of the submenu start location
    if eventPlayer.menu_index - eventPlayer.submenu_start_index[eventPlayer.submenu_index] == 0:
        # then loop to the end of the submenu
        eventPlayer.menu_index = eventPlayer.submenu_start_index[eventPlayer.submenu_index+1] - 1
    else:
        # otherwise move up 1 on the menu.
        eventPlayer.menu_index -= 1


rule "Menu Controls: Down Scroll (O - copy this)":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.menu_visable == true
    # We use the player's movement keys to navigate the menu.
    # If you'd like to use a button input instead, change this condition.
    @Condition eventPlayer.getThrottle() == Vector.BACKWARD
    
    # If the menu index is equal to the end of our submenu
    if eventPlayer.menu_index == eventPlayer.submenu_start_index[eventPlayer.submenu_index+1] - 1:
        # then loop to the start of the submenu
        eventPlayer.menu_index = eventPlayer.submenu_start_index[eventPlayer.submenu_index]
    else:
        # then move down 1 on the menu.
        eventPlayer.menu_index += 1


def enable_player_input():
    @Name "SUB: Allow Input (O - copy this)"
    # If you want to keep certain buttons disabled remove the desired allow button action from this list of actions.
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.JUMP)
    eventPlayer.allowButton(Button.ABILITY_1)
    eventPlayer.allowButton(Button.ABILITY_2)
    eventPlayer.allowButton(Button.ULTIMATE)
    # If you're trying to modify the player's movement speed, store the speed in a variable and replace the 100 with that variable.
    eventPlayer.setMoveSpeed(100)


rule "Generate Host Menu (O - copy this; this is where we create the content in the menu so change the actions in this rule according to your needs)":
    @Event playerJoined
    # This menu is unique to the host player. If you want all your players to have the same menu just remove this condition.
    # You can also add more conditions if you want to unique menus for a certain type of hero, team, etc.
    @Condition eventPlayer == hostPlayer

    # The first thing we do is default all of the player variables related to the menu.
    default_menu_variables()
    # This just creates the text you see at the left side of the screen telling you the controls. If you modify the controls for your menu, update this subroutine.
    create_settings_prompt()

    # Label - these are just text we create that the player can not interact with. Good for organizing your menu and giving tips. 
    # Modifies the posititon and the index for the array we use to store the information of our label.
    increment_for_menu_label()
    # Here we set the text for the label item
    eventPlayer.menu_label[eventPlayer.menu_label_size] = "Menu Header"
    # Here we set the color of the label to the default color we assigned in an eariler rule.
    eventPlayer.menu_label_color[eventPlayer.menu_label_size] = default_menu_label_color
    # this subroutine is where we create the hudtext using the data we populated in our array.
    new_menu_label_header()

    # item - these are the items the player can interact with. Modifies the posititon and the index for the array we use to store the information of our item.
    increment_for_menu_item()
    # Menu items can have 2 text values. One for when our menu index is not selecting the item and one for when it is.
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "Menu Selection"
    # In this case we dont want the text to change so we set menu_on_opt_title to the same as the menu_off_opt_title
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size]
    # We can also change the color of the menu when we are on the menu item. In this case we just use our default.
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    # this is an optional array used to keep track of what the player as set the menu item to. In this case we dont need it to it is set to null.
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = null
    # This creates a new menu item used for selection. These only have a title string.
    new_menu_item_selection()

    # Here we increment for our next menu item which is a toggle.
    # You can use these to turn turn on and off features, or to select a feature from a list.
    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "Menu Toggle"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = "Hi Im : "
    # In addition to our on_opt_title we can add another string to the menu item when we are on it. 
    # This lets us change just a portion of the text and lets us change title and this variable seperately
    eventPlayer.menu_opt_var[eventPlayer.menu_opt_size] = "off"
    # We set the color to this item to red by default. We change this color in the rule that handles the player's selection input.
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = Color.RED
    # Here we are using our status array to default to the off state. When player selects this menu item, we will update this array to a new value.
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = 0
    # This creates a new menu item that is used for a toggle. 
    new_menu_item_toggle()

    # Next were making a cycle menu item.
    # This is good for when you have many options and you want the user to be able to easily navigate forwards and backwards through the list.
    # Basically the same as the toggle in terms toggle in terms of functionality, but has a unique pre-defined string.
    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "Menu Cycle"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = "Hi I'll go away if you cycle"
    # This is a menu item that uses its text from an array. Here we are setting the initial variable text to the first item in the array. 
    # We use menu_opt_status to set the var text in the player selection rule
    eventPlayer.menu_opt_var[eventPlayer.menu_opt_size] = demo_var_menu_text_array[0]
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = 0
    # Here we create a cycle menu item. The difference from this and a toggle is that the menu item will look like this "{title} ←  {var}  →"
    new_menu_item_cycle()

    # Now we make a cycle bar menu item.
    # This basically the same as a cycle item but it also has a bar below it made with a hudHeader, which looks nice since it is bigger.
    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "Cycle bar"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = "Hello!"
    eventPlayer.menu_opt_var[eventPlayer.menu_opt_size] = "Im very colorful"
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    # Here we set the default values for our bar item that will appear below the menu item when we are on its index. These are similar to the values of the regular menu item.
    eventPlayer.bar_title[eventPlayer.menu_opt_size] = "Hi Im"
    eventPlayer.bar_var[eventPlayer.menu_opt_size] = active_color_list[eventPlayer.demo_cycle_menu_index]
    eventPlayer.bar_color[eventPlayer.menu_opt_size] = active_color_list[eventPlayer.demo_cycle_menu_index]
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = 0
    # Here we create a cycle bar. It is similar to a cycle menu item, except it also creates a second bar below it that can also be configured. 
    new_menu_item_cycle_bar()

    # Here were just creating a selection item used to open a submenu, we'll define it's functionality in a later rule.
    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "submenu"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = "Open submenu"
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = null
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    new_menu_item_selection()


    # This is just another label, but instead of a header it is a subtext.
    # It's good for giving the player information underneath the menu.
    increment_for_menu_label()
    eventPlayer.menu_label[eventPlayer.menu_label_size] = "\n For more info on how to configure this menu\n Go to Workshop.codesE7TAC\n There are also lots of comments in every rule of the workshop menu"
    eventPlayer.menu_label_color[eventPlayer.menu_label_size] = rgb(220,32,123)
    new_menu_label_subtext()


    # Submenu - this resets the position to zero and increments the submenu size
    # Since working with 2D arrays is annoying in the workshop, submenus are just divisions we make relative to menu_index
    increment_for_submenu_item()
    # First we just add a new header.
    increment_for_menu_label()
    eventPlayer.menu_label[eventPlayer.menu_label_size] = "Submenu Header"
    eventPlayer.menu_label_color[eventPlayer.menu_label_size] = default_menu_label_color
    new_menu_label_header()
    # Then a button to return
    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "return"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size]
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = null
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    new_menu_item_selection()
    # And then another button just for fun!
    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "another submenu button"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = "another submenu button"
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = null
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    new_menu_item_selection()


def default_menu_variables():
    @Name "SUB: default_menu_variables (O - copy this)"

    # Default menu variables
    eventPlayer.menu_index = 0
    eventPlayer.submenu_index = 0
    eventPlayer.submenu_start_index[0] = 0
    eventPlayer.submenu_start_index[1] = 1
    eventPlayer.demo_cycle_menu_index = 0
    eventPlayer.demo_cycle_menu_status = 0
    eventPlayer.menu_do_off_actions = false
    eventPlayer.menu_max_pos = -1
    eventPlayer.menu_label_size = -1
    eventPlayer.menu_opt_size = -1
    eventPlayer.sub_size = 0
    eventPlayer.menu_off_opt_color = default_menu_off_index_color
    eventPlayer.bar_title = null
    eventPlayer.bar_var = null


def create_settings_prompt():
    @Name "SUB: create_settings_prompt (O - copy this if you want the same settings prompt)"
    # Settings Headers
    hudSubheader([i for i in eventPlayer if not eventPlayer.menu_visable], 
    "Press  {0}  to change settings".format(buttonString(Button.INTERACT)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable], 
    "Press  {0}  to close menu".format(buttonString(Button.INTERACT)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable], 
    # Remember to change these if you change the controls
    "—  Controls  —", HudPosition.LEFT, 0.1, Color.BLACK, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable], 
    "Navigation: Movement Keys", HudPosition.LEFT, 0.2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable], 
    "Toggle Selection:  {0}/{1}".format(buttonString(Button.PRIMARY_FIRE),buttonString(Button.ABILITY_2)), HudPosition.LEFT, 0.3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


def increment_for_menu_label():
    @Name "SUB: increment_menu_label (O - copy this)"

    eventPlayer.menu_label_size += 1
    eventPlayer.menu_max_pos += 1


def increment_for_menu_item():
    @Name "SUB: increment_for_menu_item (O - copy this)"

    eventPlayer.menu_opt_size += 1
    eventPlayer.menu_max_pos += 1
    eventPlayer.submenu_start_index[eventPlayer.sub_size+1] = eventPlayer.menu_opt_size+1

def increment_for_submenu_item():
    @Name "SUB: increment_for_new_submenu (O - copy this)"

    eventPlayer.sub_size += 1
    eventPlayer.menu_max_pos = -1

def new_menu_label_header():
    @Name "SUB: new_menu_label_header (O - copy this)"

    hudHeader([i for i in eventPlayer if eventPlayer.menu_visable and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)], 
    "{0}".format(eventPlayer.menu_label[evalOnce(eventPlayer.menu_label_size)]),
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_label_color[evalOnce(eventPlayer.menu_label_size)],
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)


def new_menu_label_subtext():
    @Name "SUB: new_menu_label_subtext (O - copy this)"

    hudSubtext([i for i in eventPlayer if eventPlayer.menu_visable and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)], 
    "{0}".format(eventPlayer.menu_label[evalOnce(eventPlayer.menu_label_size)]),
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_label_color[evalOnce(eventPlayer.menu_label_size)],
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)
    
def new_menu_item_selection():
    @Name "SUB: new_menu_item_selection (O - copy this)"

    # Case: index off
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable and eventPlayer.menu_index != evalOnce(eventPlayer.menu_opt_size) and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)], 
    "{0}".format(eventPlayer.menu_off_opt_title[evalOnce(eventPlayer.menu_opt_size)]),
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_off_opt_color,
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)
    # Case: index on
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable and eventPlayer.menu_index == evalOnce(eventPlayer.menu_opt_size) and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)],
    "■  {0}".format(eventPlayer.menu_on_opt_title[evalOnce(eventPlayer.menu_opt_size)]),
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_on_opt_color[evalOnce(eventPlayer.menu_opt_size)],
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)


def new_menu_item_toggle():
    @Name "SUB: new_menu_item_toggle (O - copy this)"

    # Case: index off
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable and eventPlayer.menu_index != evalOnce(eventPlayer.menu_opt_size) and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)], 
    "{0}".format(eventPlayer.menu_off_opt_title[evalOnce(eventPlayer.menu_opt_size)]),
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_off_opt_color,
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)

    # Case: index on, see menu_action_toggle to see how to update the menu_opt_var string.
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable and eventPlayer.menu_index == evalOnce(eventPlayer.menu_opt_size) and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)],
    "■  {0}{1}".format(eventPlayer.menu_on_opt_title[evalOnce(eventPlayer.menu_opt_size)], eventPlayer.menu_opt_var[evalOnce(eventPlayer.menu_opt_size)]), 
    HudPosition.TOP,
    evalOnce(eventPlayer.menu_max_pos),
    eventPlayer.menu_on_opt_color[evalOnce(eventPlayer.menu_opt_size)],
    HudReeval.VISIBILITY_STRING_AND_COLOR,
    SpecVisibility.DEFAULT)


def new_menu_item_cycle():
    @Name "SUB: new_menu_item_cycle (O - copy this)"

    # Case: index off
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable and eventPlayer.menu_index != evalOnce(eventPlayer.menu_opt_size) and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)], 
    "{0}".format(eventPlayer.menu_off_opt_title[evalOnce(eventPlayer.menu_opt_size)]),
    HudPosition.TOP, 
    evalOnce(eventPlayer.menu_max_pos), 
    eventPlayer.menu_off_opt_color, 
    HudReeval.VISIBILITY_STRING_AND_COLOR, 
    SpecVisibility.DEFAULT)

    # Case: index on, see menu_action_cycle to see how to update the menu_opt_var string.
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable and eventPlayer.menu_index == evalOnce(eventPlayer.menu_opt_size) and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)], 
    "■ {0} ←  {1}  → ".format(eventPlayer.menu_on_opt_title[evalOnce(eventPlayer.menu_opt_size)], eventPlayer.menu_opt_var[evalOnce(eventPlayer.menu_opt_size)]),
    HudPosition.TOP, 
    evalOnce(eventPlayer.menu_max_pos), 
    eventPlayer.menu_on_opt_color[evalOnce(eventPlayer.menu_opt_size)], 
    HudReeval.VISIBILITY_STRING_AND_COLOR, 
    SpecVisibility.DEFAULT)


def new_menu_item_cycle_bar():
    @Name "SUB: new_menu_item_cycle_bar (O - copy this)"

    # Case: index off
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable and eventPlayer.menu_index != evalOnce(eventPlayer.menu_opt_size) and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)], 
    "cycle + toggle w/ submenu", 
    HudPosition.TOP, 
    evalOnce(eventPlayer.menu_max_pos), 
    eventPlayer.menu_off_opt_color, 
    HudReeval.VISIBILITY_STRING_AND_COLOR, 
    SpecVisibility.DEFAULT)

    # Case: index on, see menu_action_cycle_bar to see how to update the menu_opt_var string.
    hudSubheader([i for i in eventPlayer if eventPlayer.menu_visable and eventPlayer.menu_index == evalOnce(eventPlayer.menu_opt_size) and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)], 
    "■  {0}  {1}".format(eventPlayer.menu_on_opt_title[evalOnce(eventPlayer.menu_opt_size)], eventPlayer.menu_opt_var[evalOnce(eventPlayer.menu_opt_size)]), 
    HudPosition.TOP, 
    evalOnce(eventPlayer.menu_max_pos), 
    eventPlayer.menu_on_opt_color[evalOnce(eventPlayer.menu_opt_size)], 
    HudReeval.VISIBILITY_STRING_AND_COLOR, 
    SpecVisibility.DEFAULT)

    # Increment Menu Position
    eventPlayer.menu_max_pos += 1

    # Submenu hudheader
    hudHeader([i for i in eventPlayer if eventPlayer.menu_visable and eventPlayer.menu_index == evalOnce(eventPlayer.menu_opt_size) and eventPlayer.submenu_index == evalOnce(eventPlayer.sub_size)], 
    "{0} ←  {1}  →".format(eventPlayer.bar_title[eventPlayer.menu_index], eventPlayer.bar_var[eventPlayer.menu_index]), 
    HudPosition.TOP, 
    evalOnce(eventPlayer.menu_max_pos), 
    eventPlayer.bar_color[evalOnce(eventPlayer.menu_opt_size)], 
    HudReeval.VISIBILITY_STRING_AND_COLOR, 
    SpecVisibility.DEFAULT)


rule "Menu Actions: Host Player Right Action (O - copy this and modify the if conditions to execute actions / subroutines based on what you want to happen when the player presses right movment while in the menu)":
    @Event eachPlayer
    @Team 1
    # Note: This is just one way to handle a player's inputs.
    # I prefer using subroutines because I feel it is easier to organize what actions do what.
    @Condition eventPlayer.menu_visable == true
    # We use the player's movement keys to navigate the menu.
    # If you'd like to use a button input instead, change this condition.
    # Here we are doing stuff when the player moves right.
    @Condition eventPlayer.getThrottle() == Vector.RIGHT
    # You can have different actions for each of your players.
    # In this case these menu actions are exclusive to the host player.
    @Condition eventPlayer == hostPlayer
    # These are actions for the main menu, so it should only operate when the submenu is equal to 0.
    @Condition eventPlayer.submenu_index == 0

    # We use the player variable menu_input to tell the subroutines we call that the player inputed right.
    eventPlayer.menu_input = 1
    # Unfortunately to know what to do at each index, we have to hard code the index. 
    # If you add / remove / reorganize items in your menu you'll have to come back here and add / remove /reorganize the subroutines you call.
    if eventPlayer.menu_index == 2 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]:
        menu_action_cycle()
    elif eventPlayer.menu_index == 3 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]:
        menu_action_cycle_bar()
    elif eventPlayer.menu_index == 4 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]: 



rule "Menu Actions: Host Player Left Action (O - copy this and modify the if conditions to execute actions / subroutines based on what you want to happen when the player presses left movment while in the menu)":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.menu_visable == true
    # We use the player's movement keys to navigate the menu.
    # If you'd like to use a button input instead, change this condition.
    @Condition eventPlayer.getThrottle() == Vector.LEFT
    # You can have different actions for each of your players.
    # In this case these menu actions are exclusive to the host player.
    # Here we are doing stuff when the player moves left.
    @Condition eventPlayer == hostPlayer
    # These are actions for the main menu, so it should only operate when the submenu is equal to 0.
    @Condition eventPlayer.submenu_index == 0

    # We use the player variable menu_input to tell the subroutines we call that the player inputed left.
    eventPlayer.menu_input = -1

    # Unfortunately to know what to do at each index, we have to hard code the index. 
    # If you add / remove / reorganize items in your menu you'll have to come back here and add / remove /reorganize the subroutines you call.
    if eventPlayer.menu_index == 2 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]:
        menu_action_cycle()
    elif eventPlayer.menu_index == 3 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]:
        menu_action_cycle_bar()


rule "Menu Actions: Host Player Ability 2 / Primary Action (O - copy this and modify the if conditions to execute actions / subroutines based on what you want to happen when the player presses ability 2/primary fire while in the menu)":
    @Event eachPlayer
    @Condition eventPlayer.menu_visable == true
    # Here we have two button inputs that can trigger this set of menu actions.
    # If you'd like to use different button input(s) instead, change this condition.
    @Condition (eventPlayer.isHoldingButton(Button.ABILITY_2) == true or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true) == true
    # You can have different actions for each of your players.
    # In this case these menu actions are exclusive to the host player.
    @Condition eventPlayer == hostPlayer
    # These are actions for the main menu, so it should only operate when the submenu is equal to 0.
    @Condition eventPlayer.submenu_index == 0
    
    # We use the player variable menu_input to tell the subroutines we call that the player inputed one of our selection keys.
    eventPlayer.menu_input = 0

    if eventPlayer.menu_index == 0 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]:
        menu_action_selection()
    elif eventPlayer.menu_index == 1 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]:
        menu_action_toggle()
    elif eventPlayer.menu_index == 2 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]:
        menu_action_cycle()
    elif eventPlayer.menu_index == 3 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]:
        menu_action_cycle_bar()
    elif eventPlayer.menu_index == 4 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]:
        menu_action_open_submenu()


rule "Menu Actions: Host Player Sub Menu 1 Actions (X - just an example, no need to copy)":
    @Event eachPlayer
    @Condition eventPlayer.menu_visable == true
    # These are actions for a submenu triggered by rules that change the submenu index to 1
    @Condition eventPlayer.submenu_index == 1
    # Here we have two button inputs triggering this set of menu actions.
    # If you'd like to use a different button input instead, change this condition.
    @Condition (eventPlayer.isHoldingButton(Button.ABILITY_2) == true or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true) == true
    
    eventPlayer.menu_input = 0

    if eventPlayer.menu_index == 0 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]:
        menu_action_close_submenu()


rule "Menu Control: Toggle Submenu with crouch + reload (X - just an example, no need to copy)":
    @Event eachPlayer
    @Team 1
    @Hero tracer
    # You can also have multiple of toggle rules to open unique menus via unique button(s) through the use of the submenu feature. 
    # If you utilize the submenu feature you can assign different menus for unique players.
    # Here the submenu will open the player presses crouch and reload and has selected tracer.
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    

    eventPlayer.menu_visable = true
    if eventPlayer.submenu_index != 1:
        eventPlayer.submenu_index = 1
        eventPlayer.menu_index = eventPlayer.submenu_start_index[eventPlayer.submenu_index]


def menu_off_actions():
    @Name "SUB: menu_off_actions (X - these are just examples of what you can do in response to the player selecting each of the menu item types)"
    
    smallMessage(eventPlayer, "    hi you just closed the menu")


def menu_action_selection():
    @Name "SUB: menu_action_selection (X - these are just examples of what you can do in response to the player selecting each of the menu item types)"

    smallMessage(eventPlayer, "    hi im a selection action")


def menu_action_toggle():
    @Name "SUB: menu_action_toggle (X - these are just examples of what you can do in response to the player selecting each of the menu item types)"

    if eventPlayer.menu_opt_status[eventPlayer.menu_index] == 0:
        eventPlayer.menu_opt_status[eventPlayer.menu_index] = 1
        eventPlayer.menu_opt_var[eventPlayer.menu_index] = "on"
        eventPlayer.menu_on_opt_color[eventPlayer.menu_index] = Color.GREEN
        smallMessage(eventPlayer, "    hi im a toggle action: on")
        eventPlayer.menu_do_off_actions = true
    else:
        eventPlayer.menu_opt_var[eventPlayer.menu_index] = "off"
        eventPlayer.menu_opt_status[eventPlayer.menu_index] = 0
        eventPlayer.menu_on_opt_color[eventPlayer.menu_index] = Color.RED
        smallMessage(eventPlayer, "    hi im a toggle action: off")
        eventPlayer.menu_do_off_actions = false

def menu_action_cycle():
    @Name "SUB: menu_action_cycle (X - these are just examples of what you can do in response to the player selecting each of the menu item types)"

    # Actions for toggle and right movement
    if eventPlayer.menu_input >= 0:
        if eventPlayer.menu_opt_status[eventPlayer.menu_index] >= len(demo_var_menu_text_array) - 1:
            eventPlayer.menu_opt_status[eventPlayer.menu_index] = 0
        else:
            eventPlayer.menu_opt_status[eventPlayer.menu_index] += 1
        eventPlayer.menu_on_opt_title[eventPlayer.menu_index] = ""
        smallMessage(eventPlayer, "    hi you just incremented and cleared the title")
        
    else:
        if eventPlayer.menu_opt_status[eventPlayer.menu_index] <= 0:
            eventPlayer.menu_opt_status[eventPlayer.menu_index] = len(demo_var_menu_text_array) - 1
        else:
            eventPlayer.menu_opt_status[eventPlayer.menu_index] -= 1
        eventPlayer.menu_on_opt_title[eventPlayer.menu_index] = random.uniform(0,100)
        smallMessage(eventPlayer, "    hi you just decremented and changed the title")
    eventPlayer.menu_opt_var[eventPlayer.menu_index] = demo_var_menu_text_array[eventPlayer.menu_opt_status[2]]


def menu_action_cycle_bar():
    @Name "SUB: menu_action_cycle_bar (X - these are just examples of what you can do in response to the player selecting each of the menu item types)"

    if eventPlayer.menu_input == 0:
        if  eventPlayer.demo_cycle_menu_status != Color.GRAY:
            eventPlayer.demo_cycle_menu_status = Color.GRAY
            
            active_color_list[eventPlayer.demo_cycle_menu_index] = Color.GRAY
        else:
            eventPlayer.demo_cycle_menu_status = default_cycle_toggle_colors[eventPlayer.demo_cycle_menu_index]
            eventPlayer.menu_opt_var[eventPlayer.menu_index] = "I'm colorful again!"
            active_color_list[eventPlayer.demo_cycle_menu_index] = default_cycle_toggle_colors[eventPlayer.demo_cycle_menu_index]
        smallMessage(eventPlayer, "    hi you changed my color")
    elif eventPlayer.menu_input == 1:
        if eventPlayer.demo_cycle_menu_index >= len(demo_var_menu_text_array) - 1:
            eventPlayer.demo_cycle_menu_index = 0
        else:
            eventPlayer.demo_cycle_menu_index += 1
        eventPlayer.demo_cycle_menu_status = active_color_list[eventPlayer.demo_cycle_menu_index]
        smallMessage(eventPlayer, "    hi you move to the next index on the cycle bar")
    else:
        if eventPlayer.demo_cycle_menu_index <= 0:
            eventPlayer.demo_cycle_menu_index = len(demo_var_menu_text_array) - 1
        else:
            eventPlayer.demo_cycle_menu_index -= 1
        eventPlayer.demo_cycle_menu_status = active_color_list[eventPlayer.demo_cycle_menu_index]
        smallMessage(eventPlayer, "    hi you move to the previous index on the cycle bar")

    if eventPlayer.demo_cycle_menu_status != Color.GRAY:
        eventPlayer.menu_opt_var[eventPlayer.menu_index] = "I'm colorful again!"
    else:
        eventPlayer.menu_opt_var[eventPlayer.menu_index] = "I'm not very colorful"

    eventPlayer.bar_var[eventPlayer.menu_index] = active_color_list[eventPlayer.demo_cycle_menu_index]
    eventPlayer.bar_color[eventPlayer.menu_index] = active_color_list[eventPlayer.demo_cycle_menu_index]
    
def menu_action_open_submenu():
    @Name "SUB: menu_action_open_submenu (X - these are just examples of what you can do in response to the player selecting each of the menu item types)"

    # We wait until the player releases both input buttons so the rule that control the submenu's first index action does not trigger unintendedly 
    waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_2) == false and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false,9999)
    eventPlayer.submenu_index = 1
    eventPlayer.menu_index = eventPlayer.submenu_start_index[eventPlayer.submenu_index]


def menu_action_close_submenu():
    @Name "SUB: menu_action_open_submenu (X - these are just examples of what you can do in response to the player selecting each of the menu item types)"

    # We wait until the player releases both input buttons so the rule that control the submenu's first index action does not trigger unintendedly 
    waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_2) == false and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false,9999)
    eventPlayer.submenu_index = 0
    eventPlayer.menu_index = 4 + eventPlayer.submenu_start_index[eventPlayer.submenu_index]


rule "Show Server Load (X - no need to copy)":
    @Event playerJoined

    hudSubheader(eventPlayer, "Load (Curr/Avg/Peak):  {0}  /  {1}  /  {2}".format(getServerLoad(),getAverageServerLoad(),getPeakServerLoad()), HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    

rule "Initialize Demonstration Variables (X - no need to copy)":

    #These are just arrays used to demonstrate the cycle menu items
    demo_var_menu_text_array = ["hi", "im", "a", "cycle"]
    default_cycle_toggle_colors = [Color.GREEN, Color.RED, Color.BLUE, Color.ORANGE]
    active_color_list = default_cycle_toggle_colors


rule "Generate Slot 1 Non-Host Menu (X - this just an example, no need to copy)":
    @Event playerJoined
    @Condition eventPlayer != hostPlayer
    # You can create different menus for different players by adding conditions to your generate rule.
    # In this case if the player in slot 1 is not the host player, they'll get a different menu
    # If you want to code in different actions for this players menu you'll have to use a different Menu Control Rule
    @Condition eventPlayer.getSlot() == 1

    default_menu_variables()
    create_settings_prompt()

    increment_for_menu_label()
    eventPlayer.menu_label[eventPlayer.menu_label_size] = "Menu Header"
    eventPlayer.menu_label_color[eventPlayer.menu_label_size] = default_menu_label_color
    new_menu_label_header()

    increment_for_menu_item()
    eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size] = "Menu Selection"
    eventPlayer.menu_on_opt_title[eventPlayer.menu_opt_size] = eventPlayer.menu_off_opt_title[eventPlayer.menu_opt_size]
    eventPlayer.menu_opt_status[eventPlayer.menu_opt_size] = null
    eventPlayer.menu_on_opt_color[eventPlayer.menu_opt_size] = default_menu_on_index_color
    new_menu_item_selection()