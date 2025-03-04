import json

import dateparser

from rasa_sdk import Action


class ActionShowOpenHours(Action):
    def name(self):
        return "action_show_open_hours"

    def run(self, dispatcher, tracker, domain):
        opening_hours = json.load(open("../opening_hours.json", "r"))["items"]
        date = tracker.get_slot("date")
        if not date:
            date = "now"

        day = dateparser.parse(date).strftime("%A")
        opening_hours_day = opening_hours[day]
        opening_hour = opening_hours_day["open"]
        closing_hour = opening_hours_day["close"]

        if opening_hour == 0 and closing_hour == 0:
            dispatcher.utter_message(f"We are closed on {day}.")
        else:
            dispatcher.utter_message(f"We are open on {day} from {opening_hour} to {closing_hour}.")

        return []


class ActionListMenuItems(Action):
    def name(self):
        return "action_list_menu_items"

    def run(self, dispatcher, tracker, domain):
        menu_items = json.load(open("../menu.json", "r"))["items"]
        menu = [f"{item['name']} - {item['price']}" for item in menu_items]
        dispatcher.utter_message(f"Here's our menu: {', '.join(menu)}")
        return []


class ActionPlaceOrder(Action):
    def name(self):
        return "action_place_order"

    def run(self, dispatcher, tracker, domain):
        food_item = tracker.get_slot("order")
        additional_request = tracker.get_slot("additional_request")

        menu_items = json.load(open("../menu.json", "r"))["items"]
        print(food_item)
        is_order_valid = False
        for item in menu_items:
            if item['name'].lower() == food_item.lower():
                order_text = f"Thank you for your order!\n You've ordered: {food_item}\n"
                if additional_request:
                    order_text += f"Additional note: {additional_request}\n"
                order_text += f"Price is: {item['price']}\n"
                order_text += f"Preparation time is: {item['preparation_time']} hour\n"
                dispatcher.utter_message(text=order_text)
                is_order_valid = True
                break

        if not is_order_valid:
            dispatcher.utter_message(text="Invalid menu item. Please choose from our menu.")

        return []
