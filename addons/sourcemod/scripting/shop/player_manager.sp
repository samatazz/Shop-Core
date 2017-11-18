KeyValues h_KvClientItems[MAXPLAYERS+1];

KeyValues kv_data;
char data_path[PLATFORM_MAX_PATH];

int i_Id[MAXPLAYERS+1];
int iCredits[MAXPLAYERS+1];

ConVar g_hTimerMethod, g_hStartCredits;
bool g_bTimerMethod;
int g_iStartCredits;

void PlayerManager_CreateNatives()
{
	CreateNative("Shop_IsAuthorized", PlayerManager_IsAuthorized);
	CreateNative("Shop_IsAdmin", PlayerManager_IsAdmin);
	CreateNative("Shop_GetClientId", PlayerManager_GetClientId);
	CreateNative("Shop_GetClientCredits", PlayerManager_GetClientCredits);
	CreateNative("Shop_SetClientCredits", PlayerManager_SetClientCredits);
	CreateNative("Shop_GiveClientCredits", PlayerManager_GiveClientCredits);
	CreateNative("Shop_TakeClientCredits", PlayerManager_TakeClientCredits);
	CreateNative("Shop_BuyClientItem", PlayerManager_BuyClientItem);
	CreateNative("Shop_UseClientItem", PlayerManager_UseClientItem);
	CreateNative("Shop_RemoveClientItem", PlayerManager_RemoveClientItem);
	CreateNative("Shop_GiveClientItem", PlayerManager_GiveClientItem);
	CreateNative("Shop_GetClientItemCount", PlayerManager_GetClientItemCount);
	CreateNative("Shop_SetClientItemCount", PlayerManager_SetClientItemCount);
	CreateNative("Shop_SetClientItemTimeleft", PlayerManager_SetClientItemTimeleft);
	CreateNative("Shop_GetClientItemTimeleft", PlayerManager_GetClientItemTimeleft);
	CreateNative("Shop_GetClientItemSellPrice", PlayerManager_GetClientItemSellPrice);
	CreateNative("Shop_IsClientItemToggled", PlayerManager_IsClientItemToggled);
	CreateNative("Shop_IsClientHasItem", PlayerManager_IsClientHasItem);
	CreateNative("Shop_ToggleClientItem", PlayerManager_ToggleClientItem);
	CreateNative("Shop_ToggleClientCategoryOff", PlayerManager_ToggleClientCategoryOff);
}

public int PlayerManager_IsAuthorized(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	return PlayerManager_IsAuthorizedIn(client);
}

public int PlayerManager_IsAdmin(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	return IsAdmin(client);
}

bool PlayerManager_IsAuthorizedIn(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && i_Id[client] != 0);
}

public int PlayerManager_GetClientId(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	return i_Id[client];
}

public int PlayerManager_GetClientCredits(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	return PlayerManager_GetCredits(client);
}

public int PlayerManager_SetClientCredits(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	PlayerManager_SetCredits(client, GetNativeCell(2));
}

public int PlayerManager_GiveClientCredits(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	return GiveCredits(client, GetNativeCell(2), GetNativeCell(3));
}

public int PlayerManager_TakeClientCredits(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	return RemoveCredits(client, GetNativeCell(2), GetNativeCell(3));
}

public int PlayerManager_BuyClientItem(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	int item_id = GetNativeCell(2);
	
	return BuyItem(client, item_id, true);
}

public int PlayerManager_UseClientItem(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	int item_id = GetNativeCell(2);
	
	return UseItem(client, item_id, true);
}

public int PlayerManager_RemoveClientItem(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	int item_id = GetNativeCell(2);
	int count = GetNativeCell(3);
	
	return PlayerManager_RemoveItem(client, item_id, count);
}

public int PlayerManager_GiveClientItem(Handle plugin, int numParams)
{
	int client;
	char item[SHOP_MAX_STRING_LENGTH];
	client = GetNativeCell(1);
	if (!CheckClient(client, item, sizeof(item)))
		ThrowNativeError(SP_ERROR_NATIVE, item);

	int item_id;
	char sItemId[16];
	int category_id, price, sell_price, count, duration;
	ItemType type;
	item_id = GetNativeCell(2);

	IntToString(item_id, sItemId, sizeof(sItemId));

	if (!ItemManager_GetItemInfoEx(sItemId, item, sizeof(item), category_id, price, sell_price, count, duration, type))
		return false;

	if(type == Item_Togglable)
		duration = GetNativeCell(3);
	else if(type == Item_Finite)
		count = GetNativeCell(3);

	PlayerManager_GiveItemEx(client, sItemId, category_id, price, sell_price, count, duration, type);

	return true;
}

public int PlayerManager_GetClientItemCount(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	int item_id = GetNativeCell(2);
	
	return PlayerManager_GetItemCount(client, item_id);
}

public int PlayerManager_SetClientItemCount(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	int item_id = GetNativeCell(2);
	
	PlayerManager_SetItemCount(client, item_id, GetNativeCell(3));
}

public int PlayerManager_GetClientItemSellPrice(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	int item_id = GetNativeCell(2);
	
	return PlayerManager_GetItemSellPrice(client, item_id);
}

public int PlayerManager_SetClientItemTimeleft(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	int timeleft = GetNativeCell(3);
	if (timeleft < 0)
		timeleft = 0;
	
	return PlayerManager_SetItemTimeleft(client, GetNativeCell(2), timeleft);
}

public int PlayerManager_GetClientItemTimeleft(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	return PlayerManager_GetItemTimeleft(client, GetNativeCell(2));
}

public int PlayerManager_IsClientItemToggled(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	int item_id = GetNativeCell(2);
	
	return PlayerManager_IsItemToggled(client, item_id);
}

public int PlayerManager_IsClientHasItem(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	int item_id = GetNativeCell(2);
	
	return PlayerManager_ClientHasItem(client, item_id);
}

public int PlayerManager_ToggleClientItem(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	int item_id = GetNativeCell(2);
	ToggleState toggle = GetNativeCell(3);
	
	return ToggleItem(client, item_id, toggle, true);
}

void PlayerManager_OnPluginStart()
{
	HookEventEx("player_changename", PlayerManager_OnPlayerName);
	
	BuildPath(Path_SM, data_path, sizeof(data_path), "data/shop.txt");
	
	kv_data = new KeyValues("ShopData");
	if (kv_data.ImportFromFile(data_path))
	{
		char buffer[11];
		kv_data.GetString("version", buffer, sizeof(buffer));
		if (buffer[0])
		{
			if (buffer[0] == '1')
			{
				while (kv_data.GotoFirstSubKey())
				{
					kv_data.DeleteThis();
					kv_data.Rewind();
				}
				kv_data.ExportToFile(data_path);
			}
		}
	}
	
	g_hStartCredits = CreateConVar("sm_shop_start_credits", "0", "Start credits for a new player", 0, true, 0.0);
	g_iStartCredits = g_hStartCredits.IntValue;
	g_hStartCredits.AddChangeHook(PlayerManager_OnConVarChange);
	
	g_hTimerMethod = CreateConVar("sm_shop_timer_method", "0", "Timing method to use for timed items. 0 time while using and 1 is real time", 0, true, 0.0, true, 1.0);
	g_bTimerMethod = g_hTimerMethod.BoolValue;
	g_hTimerMethod.AddChangeHook(PlayerManager_OnConVarChange);
}

void PlayerManager_OnReadyToStart()
{
	kv_data.SetString("version", SHOP_VERSION);
	kv_data.ExportToFile(data_path);
}

public void PlayerManager_OnConVarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar == g_hStartCredits)
		g_iStartCredits = convar.IntValue;
	else if (convar == g_hTimerMethod)
		g_bTimerMethod = convar.BoolValue;
}

void PlayerManager_OnMapEnd()
{
	kv_data.ExportToFile(data_path);
}

void PlayerManager_OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)
		PlayerManager_SaveInfo(i);
	
	kv_data.ExportToFile(data_path);
}

void PlayerManager_TransferItem(int client, int target, int item_id)
{
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	
	ItemType type = GetItemTypeEx(sItemId);
	
	if (type == Item_Finite)
	{
		RemoveItemEx(client, sItemId);
		GiveItemEx(target, sItemId);
	}
	else
	{
		if (PlayerManager_IsItemToggledEx(client, sItemId))
			PlayerManager_ToggleItemEx(client, sItemId, Shop_UseOff);
		
		if (!h_KvClientItems[client].JumpToKey(sItemId))
			return;
		
		h_KvClientItems[target].JumpToKey(sItemId, true);
		KvCopySubkeys(h_KvClientItems[client], h_KvClientItems[target]);
		h_KvClientItems[client].Rewind();
		
		int timeleft = PlayerManager_GetItemTimeleftEx(client, sItemId);
		
		RemoveItemEx(client, sItemId);
		
		if (h_KvClientItems[target].GetNum("method") == 1)
		{
			DataPack dp;
			Handle timer = CreateDataTimer(float(timeleft), PlayerManager_OnPlayerItemElapsed, dp);
			
			h_KvClientItems[target].SetNum("timer", view_as<int>(timer));
			dp.WriteCell(target);
			dp.WriteCell(item_id);
		}
	
		char s_Query[256];
		FormatEx(s_Query, sizeof(s_Query), "INSERT INTO `%sboughts` (`player_id`, `item_id`, `count`, `duration`, `timeleft`, `buy_price`, `sell_price`, `buy_time`) VALUES \
											('%d', '%s', '%d', '%d', '%d', '%d', '%d', '%d');", g_sDbPrefix, i_Id[target], sItemId, h_KvClientItems[target].GetNum("count"), h_KvClientItems[target].GetNum("duration"), timeleft, h_KvClientItems[target].GetNum("price"), h_KvClientItems[target].GetNum("sell_price"), h_KvClientItems[target].GetNum("buy_time"));
		TQueryEx(s_Query, DBPrio_High);
		
		int category_id = h_KvClientItems[target].GetNum("category_id");
		
		h_KvClientItems[target].Rewind();
		
		char sCat[16];
		IntToString(category_id, sCat, sizeof(sCat));
		StrCat(sCat, sizeof(sCat), "c");
		h_KvClientItems[target].SetNum(sCat, h_KvClientItems[target].GetNum(sCat, 0)+1);
	}
}

bool PlayerManager_IsItemToggled(int client, int item_id)
{
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	
	return PlayerManager_IsItemToggledEx(client, sItemId);
}

bool PlayerManager_IsItemToggledEx(int client, const char[] sItemId)
{
	char sId[16];
	IntToString(i_Id[client], sId, sizeof(sId));
	
	bool result = false;
	
	if (!kv_data.JumpToKey(sId))
		return result;
	
	result = view_as<bool>(kv_data.GetNum(sItemId, 0) != 0);
	
	kv_data.Rewind();
	
	return result;
}

bool PlayerManager_ToggleItem(int client, int item_id, ShopAction action, bool load = false)
{
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	
	return PlayerManager_ToggleItemEx(client, sItemId, action, load);
}

bool PlayerManager_ToggleItemEx(int client, const char[] sItemId, ShopAction action, bool load = false, bool ingore = false)
{
	char sId[16];
	IntToString(i_Id[client], sId, sizeof(sId));
	
	if (!h_KvClientItems[client].JumpToKey(sItemId))
		return false;
	
	bool result = false;
	
	int item_id = StringToInt(sItemId);
	
	kv_data.JumpToKey(sId, true);
	switch (action)
	{
		case Shop_UseOn :
		{
			if (load || kv_data.GetNum(sItemId, 0) == 0)
			{
				int duration = h_KvClientItems[client].GetNum("duration");
				if (duration > 0)
				{
					int timeleft;
					if (h_KvClientItems[client].GetNum("method") == 0)
					{
						timeleft = h_KvClientItems[client].GetNum("timeleft");
						
						Handle timer = view_as<Handle>(h_KvClientItems[client].GetNum("timer", 0));
						if (timer != null)
							KillTimer(timer);
						
						DataPack dp;
						timer = CreateDataTimer(float(timeleft), PlayerManager_OnPlayerItemElapsed, dp);
						
						h_KvClientItems[client].SetNum("timer", view_as<int>(timer));
						dp.WriteCell(client);
						dp.WriteCell(item_id);
					}
					h_KvClientItems[client].SetNum("started", global_timer);
					/*else
					{
						timeleft = h_KvClientItems[client].GetNum("duration")+h_KvClientItems[client].GetNum("buy_time")-global_timer;
					}*/
				}
				
				kv_data.SetNum(sItemId, 1);
				
				if (!ingore)
					OnItemEquipped(client, item_id);
				
				result = true;
			}
		}
		case Shop_UseOff :
		{
			if (load || kv_data.GetNum(sItemId, 0) != 0)
			{
				int duration = h_KvClientItems[client].GetNum("duration");
				if (duration > 0)
				{
					if (h_KvClientItems[client].GetNum("method") == 0)
					{
						Handle timer = view_as<Handle>(h_KvClientItems[client].GetNum("timer", 0));
						if (timer != null)
						{
							KillTimer(timer);
							h_KvClientItems[client].SetNum("timer", 0);
						}
					}
					
					int started = h_KvClientItems[client].GetNum("started");
					if (started)
					{
						int timeleft = h_KvClientItems[client].GetNum("timeleft");
						h_KvClientItems[client].SetNum("timeleft", timeleft-(global_timer-started));
					}
					h_KvClientItems[client].SetNum("started", 0);
				}
				
				kv_data.DeleteKey(sItemId);
				if (!ingore)
					OnItemDequipped(client, item_id);
				
				result = true;
			}
		}
	}
	
	h_KvClientItems[client].Rewind();
	kv_data.Rewind();
	
	return result;
}

public int PlayerManager_ToggleClientCategoryOff(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	char error[64];
	if (!CheckClient(client, error, sizeof(error)))
		ThrowNativeError(SP_ERROR_NATIVE, error);
	
	int category_id = GetNativeCell(2);
	
	if (!h_KvClientItems[client].GotoFirstSubKey())
		return;
	
	char sId[16];
	IntToString(i_Id[client], sId, sizeof(sId));
	kv_data.JumpToKey(sId, true);
	
	char sItemId[16];
	do
	{
		if (h_KvClientItems[client].GetNum("category_id", -1) != category_id || !KvGetSectionName(h_KvClientItems[client], sItemId, sizeof(sItemId)))
			continue;
		
		int duration = h_KvClientItems[client].GetNum("duration");
		
		if (duration > 0)
		{
			Handle timer = view_as<Handle>(h_KvClientItems[client].GetNum("timer", 0));
			if (timer != null)
			{
				if (h_KvClientItems[client].GetNum("method") == 0)
				{
					KillTimer(timer);
					h_KvClientItems[client].SetNum("timer", 0);
				}
			}
			int started = h_KvClientItems[client].GetNum("started", 0);
			if (started)
			{
				int timeleft = h_KvClientItems[client].GetNum("timeleft");
				
				h_KvClientItems[client].SetNum("timeleft", timeleft-(global_timer-started));
				h_KvClientItems[client].SetNum("started", 0);
			}
		}
		
		if (kv_data.GetNum(sItemId, 0) != 0)
		{
			h_KvClientItems[client].Rewind();
			OnItemDequipped(client, StringToInt(sItemId));
			h_KvClientItems[client].JumpToKey(sItemId);
			
			kv_data.DeleteKey(sItemId);
		}
	}
	while (h_KvClientItems[client].GotoNextKey());
	
	h_KvClientItems[client].Rewind();
	kv_data.Rewind();
}

public Action PlayerManager_OnPlayerItemElapsed(Handle timer, DataPack dp)
{
	dp.Reset();
	int client = dp.ReadCell();
	int item_id = dp.ReadCell();
	
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	
	char s_Query[256];
	FormatEx(s_Query, sizeof(s_Query), "DELETE FROM `%sboughts` WHERE `player_id` = '%d' AND `item_id` = '%d';", g_sDbPrefix, i_Id[client], item_id);
	TQueryEx(s_Query, DBPrio_High);
	
	if (h_KvClientItems[client].JumpToKey(sItemId))
	{
		int category_id = h_KvClientItems[client].GetNum("category_id", -1);
		h_KvClientItems[client].DeleteThis();
		
		h_KvClientItems[client].Rewind();
		
		IntToString(category_id, sItemId, sizeof(sItemId));
		StrCat(sItemId, sizeof(sItemId), "c");
		h_KvClientItems[client].SetNum(sItemId, h_KvClientItems[client].GetNum(sItemId, 0)-1);
	}
	
	OnPlayerItemElapsed(client, item_id);
}

stock bool PlayerManager_CanPreviewEx(int client, const char[] sItemId, int &sec)
{
	if (!h_KvClientItems[client].JumpToKey(sItemId))
		return false;
	
	bool result = false;
	
	sec = global_timer - h_KvClientItems[client].GetNum("next_preview", 0);
	
	if (sec >= 0)
	{
		result = true;
		sec = global_timer+5;
		h_KvClientItems[client].SetNum("next_preview", sec);
	}
	
	h_KvClientItems[client].Rewind();
	
	return result;
}

void PlayerManager_GiveItemEx(int client, const char[] sItemId, int category_id, int price, int sell_price, int count, int duration, ItemType type)
{
	h_KvClientItems[client].JumpToKey(sItemId, true);
	h_KvClientItems[client].SetNum("category_id", category_id);
	h_KvClientItems[client].SetNum("price", price);
	h_KvClientItems[client].SetNum("sell_price", sell_price);
	int has = h_KvClientItems[client].GetNum("count", 0);
	h_KvClientItems[client].SetNum("count", has+count);
	h_KvClientItems[client].SetNum("timeleft", duration);
	h_KvClientItems[client].SetNum("duration", duration);
	h_KvClientItems[client].SetNum("method", g_bTimerMethod);
	if (duration > 0 && (g_bTimerMethod != false || type == Item_None))
	{
		DataPack dp;
		Handle timer = CreateDataTimer(float(duration), PlayerManager_OnPlayerItemElapsed, dp);
		
		h_KvClientItems[client].SetNum("timer", view_as<int>(timer));
		dp.WriteCell(client);
		dp.WriteCell(StringToInt(sItemId));
	}
	h_KvClientItems[client].SetNum("buy_time", global_timer);
	h_KvClientItems[client].Rewind();
	
	PlayerManager_ToggleItemEx(client, sItemId, Shop_UseOff, _, true);
	
	char s_Query[256];
	if (has < 1)
	{
		char sCat[16];
		IntToString(category_id, sCat, sizeof(sCat));
		StrCat(sCat, sizeof(sCat), "c");
		h_KvClientItems[client].SetNum(sCat, h_KvClientItems[client].GetNum(sCat, 0)+1);
		
		FormatEx(s_Query, sizeof(s_Query), "INSERT INTO `%sboughts` (`player_id`, `item_id`, `count`, `duration`, `timeleft`, `buy_price`, `sell_price`, `buy_time`) VALUES \
											('%d', '%s', '%d', '%d', '%d', '%d', '%d', '%d');", g_sDbPrefix, i_Id[client], sItemId, count, duration, duration, price, sell_price, global_timer);
		TQueryEx(s_Query, DBPrio_High);
	}
	else
	{
		FormatEx(s_Query, sizeof(s_Query), "UPDATE `%sboughts` SET `count` = '%d' WHERE `player_id` = '%d' AND `item_id` = '%s';", g_sDbPrefix, has+count, i_Id[client], sItemId);
		TQueryEx(s_Query, DBPrio_High);
	}
}

int PlayerManager_GetItemSellPrice(int client, int item_id)
{
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	
	return PlayerManager_GetItemSellPriceEx(client, sItemId);
}

int PlayerManager_GetItemSellPriceEx(int client, const char[] sItemId)
{
	if (!h_KvClientItems[client].JumpToKey(sItemId))
		return -1;
	
	bool method = view_as<bool>(h_KvClientItems[client].GetNum("method"));
	
	int sell_price = h_KvClientItems[client].GetNum("sell_price", -1);
	if (sell_price < 0)
	{
		h_KvClientItems[client].Rewind();
		return -1;
	}
	int duration = h_KvClientItems[client].GetNum("duration", 0);
	if (duration < 1)
	{
		h_KvClientItems[client].Rewind();
		return sell_price;
	}
	
	int timeleft;
	if (method == false)
	{
		int started = h_KvClientItems[client].GetNum("started", 0);
		if (started)
			timeleft = h_KvClientItems[client].GetNum("timeleft", 0)-(global_timer-started);
		else
			timeleft = h_KvClientItems[client].GetNum("timeleft", 0);
	}
	else
		timeleft = h_KvClientItems[client].GetNum("buy_time", 0)+duration-global_timer;
	
	h_KvClientItems[client].Rewind();

	int credits = sell_price;
	int dummy = credits;
	
	if (timeleft > 0)
		credits = RoundToNearest(float(credits) * float(timeleft) / float(duration));
	
	if (credits > sell_price)
		credits = sell_price;
	else if (credits < 0)
		credits = RoundToNearest(float(dummy) / 2.0 * float(timeleft) / float(duration));
	
	return credits;
}

int PlayerManager_GetClientCategorySize(int client, int category_id)
{
	char sCat[16];
	IntToString(category_id, sCat, sizeof(sCat));
	StrCat(sCat, sizeof(sCat), "c");
	
	return h_KvClientItems[client].GetNum(sCat);
}

stock bool PlayerManager_RemoveItem(int client, int item_id, int count = 1)
{
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	
	return PlayerManager_RemoveItemEx(client, sItemId, count);
}

bool PlayerManager_RemoveItemEx(int client, const char[] sItemId, int count = 1)
{
	if (!h_KvClientItems[client].JumpToKey(sItemId))
		return false;
	
	char s_Query[256];
	
	bool deleted = false;
	int category_id;
	
	int left = h_KvClientItems[client].GetNum("count", 1)-count;
	if (count < 1 || left < 1)
	{
		Handle timer = view_as<Handle>(h_KvClientItems[client].GetNum("timer", 0));
		if (timer != null)
			KillTimer(timer);
		
		category_id = h_KvClientItems[client].GetNum("category_id", -1);
		h_KvClientItems[client].DeleteThis();
		
		deleted = true;
		
		FormatEx(s_Query, sizeof(s_Query), "DELETE FROM `%sboughts` WHERE `player_id` = '%d' AND `item_id` = '%s';", g_sDbPrefix, i_Id[client], sItemId);
		TQueryEx(s_Query, DBPrio_High);
	}
	else
	{
		h_KvClientItems[client].SetNum("count", left);
		
		FormatEx(s_Query, sizeof(s_Query), "UPDATE `%sboughts` SET `count` = '%d' WHERE `player_id` = '%d' AND `item_id` = '%s';", g_sDbPrefix, left, i_Id[client], sItemId);
		TQueryEx(s_Query, DBPrio_High);
	}
	
	h_KvClientItems[client].Rewind();
	
	if (deleted)
	{
		char sCat[16];
		IntToString(category_id, sCat, sizeof(sCat));
		StrCat(sCat, sizeof(sCat), "c");
		h_KvClientItems[client].SetNum(sCat, h_KvClientItems[client].GetNum(sCat, 0)-1);
		
		PlayerManager_ToggleItem(client, StringToInt(sItemId), Shop_UseOff);
	}
	
	return true;
}

stock bool PlayerManager_ClientHasItem(int client, int item_id)
{
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	
	return PlayerManager_ClientHasItemEx(client, sItemId);
}

stock bool PlayerManager_ClientHasItemEx(int client, const char[] sItemId)
{
	bool result = h_KvClientItems[client].JumpToKey(sItemId);
	h_KvClientItems[client].Rewind();
	
	return result;
}

bool PlayerManager_SetItemTimeleft(int client, int item_id, int timeleft)
{
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	
	return PlayerManager_SetItemTimeleftEx(client, sItemId, timeleft);
}

bool PlayerManager_SetItemTimeleftEx(int client, const char[] sItemId, int timeleft)
{
	if (!h_KvClientItems[client].JumpToKey(sItemId))
		return false;
	
	Handle timer = view_as<Handle>(h_KvClientItems[client].GetNum("timer", 0));
	if (timer != null)
		KillTimer(timer);
	
	if (timeleft < 1)
		timer = null;
	else if (timer != null)
	{
		DataPack dp;
		timer = CreateDataTimer(float(timeleft), PlayerManager_OnPlayerItemElapsed, dp);
		dp.WriteCell(client);
		dp.WriteCell(StringToInt(sItemId));
	}
	else
		timer = null;
	
	h_KvClientItems[client].SetNum("timer", view_as<int>(timer));

	int duration = h_KvClientItems[client].GetNum("duration");
	if(timeleft)
	{
		if (duration < timeleft)
		{
			duration = timeleft;
			h_KvClientItems[client].SetNum("duration", duration);
		}
		
		h_KvClientItems[client].SetNum("timeleft", timeleft);
	}
	else
	{
		duration = timeleft;
		h_KvClientItems[client].SetNum("duration", 0);
	}

	h_KvClientItems[client].SetNum("timeleft", timeleft);

	char s_Query[512];
	FormatEx(s_Query, sizeof(s_Query), "UPDATE `%sboughts` SET `duration` = '%d', `timeleft` = '%d' WHERE `player_id` = '%d' AND `item_id` = '%s';", g_sDbPrefix, duration, timeleft, i_Id[client], sItemId);
	TQueryEx(s_Query, DBPrio_High);
	
	h_KvClientItems[client].Rewind();
	
	return true;
}

int PlayerManager_GetItemTimeleft(int client, int item_id)
{
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	
	return PlayerManager_GetItemTimeleftEx(client, sItemId);
}

int PlayerManager_GetItemTimeleftEx(int client, const char[] sItemId)
{
	if (!h_KvClientItems[client].JumpToKey(sItemId))
		return 0;
	
	int timeleft = 0;
	
	int duration = h_KvClientItems[client].GetNum("duration");
	if (duration > 0)
	{
		bool method = view_as<bool>(h_KvClientItems[client].GetNum("method"));
		if (method == false)
		{
			timeleft = h_KvClientItems[client].GetNum("timeleft");
			int started = h_KvClientItems[client].GetNum("started", 0);
			if (started)
				timeleft = timeleft-(global_timer-started);
		}
		else
		{
			timeleft = h_KvClientItems[client].GetNum("buy_time", 0)+duration-global_timer;
		}
	}
	
	h_KvClientItems[client].Rewind();
	
	return timeleft;
}

int PlayerManager_GetItemCount(int client, int item_id)
{
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	
	return PlayerManager_GetItemCountEx(client, sItemId);
}

int PlayerManager_GetItemCountEx(int client, const char[] sItemId)
{
	int result = 0;
	
	if (h_KvClientItems[client].JumpToKey(sItemId))
	{
		result = h_KvClientItems[client].GetNum("count");
		h_KvClientItems[client].Rewind();
	}
	
	return result;
}

void PlayerManager_SetItemCount(int client, int item_id, int count)
{
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	h_KvClientItems[client].Rewind();
	if (h_KvClientItems[client].JumpToKey(sItemId))
	{
		h_KvClientItems[client].SetNum("count", count);
		h_KvClientItems[client].Rewind();
		
		char s_Query[256];
		FormatEx(s_Query, sizeof(s_Query), "UPDATE `%sboughts` SET `count` = '%d' WHERE `player_id` = '%d' AND `item_id` = '%s';", g_sDbPrefix, count, i_Id[client], sItemId);
		TQueryEx(s_Query, DBPrio_High);
	}
}

public void PlayerManager_OnPlayerName(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client || !i_Id[client]) return;
	
	char newname[MAX_NAME_LENGTH], buffer[65], s_Query[256];
	event.GetString("newname", newname, sizeof(newname));
	EscapeString(newname, buffer, sizeof(buffer));
	FormatEx(s_Query, sizeof(s_Query), "UPDATE `%splayers` SET `name` = '%s' WHERE `id` = '%i';", g_sDbPrefix, buffer, i_Id[client]);
	TQueryEx(s_Query, DBPrio_Low);
}

void PlayerManager_DatabaseClear()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i_Id[i] != 0)
		{
			PlayerManager_ClearPlayer(i);
			PlayerManager_OnClientPutInServer(i);
		}
	}
}

bool PlayerManager_IsInGame(int player_id)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i_Id[i] != 0 && i_Id[i] == player_id)
		{
			return true;
		}
	}
	return false;
}

void PlayerManager_OnClientPutInServer(int client)
{
	if (h_KvClientItems[client] == null)
		h_KvClientItems[client] = new KeyValues("Items");
	
	char auth[22];
	GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth), false);
	
	char s_Query[256];
	if (db_type == DB_MySQL)
		FormatEx(s_Query, sizeof(s_Query), "SELECT `money`, `id` FROM `%splayers` WHERE `auth` REGEXP '^STEAM_[0-9]:%s$';", g_sDbPrefix, auth[8]);
	else
		FormatEx(s_Query, sizeof(s_Query), "SELECT `money`, `id` FROM `%splayers` WHERE `auth` = '%s';", g_sDbPrefix, auth);
	
	DataPack dp = new DataPack();
	dp.WriteCell(GetClientSerial(client));
	dp.WriteString(auth);
	dp.WriteCell(0);
	
	TQuery(PlayerManager_AuthorizeClient, s_Query, dp, DBPrio_Low);
}

public int PlayerManager_AuthorizeClient(Handle owner, Handle hndl, const char[] error, DataPack dp)
{
	if (owner == null)
	{
		delete dp;
		TryConnect();
		return;
	}
	
	if (hndl == null || error[0])
	{
		delete dp;
		LogError("PlayerManager_AuthorizeClient: %s", error);
		return;
	}
	
	dp.Reset();
	int serial = dp.ReadCell();
	int client = GetClientFromSerial(serial);
	if (!client)
	{
		delete dp;
		return;
	}
	char auth[22];
	dp.ReadString(auth, sizeof(auth));
	int iTry = dp.ReadCell();
	
	switch (iTry)
	{
		case 0 :
		{
			char name[MAX_NAME_LENGTH], buffer[65];
			GetClientName(client, name, sizeof(name));
			EscapeString(name, buffer, sizeof(buffer));
			
			char s_Query[256];
			if (!SQL_FetchRow(hndl))
			{
				ResetPack(dp, true);
				dp.WriteCell(serial);
				dp.WriteString(auth);
				dp.WriteCell(1);
				dp.WriteCell(g_iStartCredits);
				
				FormatEx(s_Query, sizeof(s_Query), "INSERT INTO `%splayers` (`name`, `auth`, `money`, `lastconnect`) VALUES ('%s', '%s', '%d', '%d');", g_sDbPrefix, buffer, auth, g_iStartCredits, global_timer);
				TQuery(PlayerManager_AuthorizeClient, s_Query, dp, DBPrio_Low);
				
				return;
			}
			iCredits[client] = SQL_FetchInt(hndl, 0);
			i_Id[client] = SQL_FetchInt(hndl, 1);
			
			PlayerManager_LoadClientItems(client);
			
			FormatEx(s_Query, sizeof(s_Query), "UPDATE `%splayers` SET `name` = '%s', `lastconnect` = '%d' WHERE `id` = '%i';", g_sDbPrefix, buffer, global_timer, i_Id[client]);
			TQueryEx(s_Query, DBPrio_Low);
		}
		case 1 :
		{
			iCredits[client] = dp.ReadCell();
			i_Id[client] = SQL_GetInsertId(hndl);
		}
	}
	delete dp;
	
	OnAuthorized(client);
}

void PlayerManager_LoadClientItems(int client)
{
	char s_Query[256];
	FormatEx(s_Query, sizeof(s_Query), "SELECT `item_id`, `count`, `duration`, `timeleft`, `buy_price`, `sell_price`, `buy_time` FROM `%sboughts`, `%sitems` WHERE `id` = `item_id` AND `player_id` = '%i';", g_sDbPrefix, g_sDbPrefix, i_Id[client]);
	TQuery(PlayerManager_GetItemsFromDB, s_Query, GetClientSerial(client), DBPrio_Low);
}

public int PlayerManager_GetItemsFromDB(Handle owner, Handle hndl, const char[] error, any serial)
{
	if (owner == null)
	{
		TryConnect();
		return;
	}
	
	if (hndl == null || error[0])
	{
		LogError("PlayerManager_GetItemsFromDB: %s", error);
		return;
	}
	
	int client = GetClientFromSerial(serial);
	if (!client)
		return;
	
	char sItemId[16], s_Query[256];
	while (SQL_FetchRow(hndl))
	{
		int item_id = SQL_FetchInt(hndl, 0);
		int buy_time = SQL_FetchInt(hndl, 6);
		int duration = SQL_FetchInt(hndl, 2);
		int timeleft = SQL_FetchInt(hndl, 3);
		
		if (duration > 0 && ((g_bTimerMethod == false && timeleft < 1) || (g_bTimerMethod != false && global_timer - buy_time > duration)))
		{
			FormatEx(s_Query, sizeof(s_Query), "DELETE FROM `%sboughts` WHERE `player_id` = '%d' AND `item_id` = '%d';", g_sDbPrefix, i_Id[client], item_id);
			TQueryEx(s_Query, DBPrio_High);
			continue;
		}
		
		IntToString(item_id, sItemId, sizeof(sItemId));
		
		if (!IsItemExistsEx(sItemId)) continue;
		
		if (duration < 1)
		{
			duration = GetItemDurationEx(sItemId);
			timeleft = duration;
			if (duration > 0)
			{
				int total = global_timer+duration-buy_time;
				FormatEx(s_Query, sizeof(s_Query), "UPDATE `%sboughts` SET `duration` = '%d', `timeleft` = '%d' WHERE `player_id` = '%d' AND `item_id` = '%d';", g_sDbPrefix, total, timeleft, i_Id[client], item_id);
				TQueryEx(s_Query, DBPrio_High);
			}
		}
		
		int category_id = GetItemCategoryIdEx(sItemId);
		
		if (h_KvClientItems[client].JumpToKey(sItemId))
		{
			Handle timer = view_as<Handle>(h_KvClientItems[client].GetNum("timer", 0));
			if (timer != null)
			{
				KillTimer(timer);
				h_KvClientItems[client].SetNum("timer", 0);
			}
		}
		else
		{
			char cat_count[16];
			IntToString(category_id, cat_count, sizeof(cat_count));
			StrCat(cat_count, sizeof(cat_count), "c");
			h_KvClientItems[client].SetNum(cat_count, h_KvClientItems[client].GetNum(cat_count, 0)+1);
			
			h_KvClientItems[client].JumpToKey(sItemId, true);
		}
		
		h_KvClientItems[client].SetNum("category_id", category_id);
		h_KvClientItems[client].SetNum("count", SQL_FetchInt(hndl, 1));
		h_KvClientItems[client].SetNum("duration", duration);
		h_KvClientItems[client].SetNum("timeleft", timeleft);
		h_KvClientItems[client].SetNum("price", SQL_FetchInt(hndl, 4));
		h_KvClientItems[client].SetNum("sell_price", SQL_FetchInt(hndl, 5));
		h_KvClientItems[client].SetNum("method", g_bTimerMethod);
		h_KvClientItems[client].SetNum("buy_time", buy_time);
		if (duration > 0 && (g_bTimerMethod != false || GetItemTypeEx(sItemId) == Item_None))
		{
			DataPack dp;
			Handle timer = CreateDataTimer(float(buy_time+duration-global_timer), PlayerManager_OnPlayerItemElapsed, dp);
			
			h_KvClientItems[client].SetNum("timer", view_as<int>(timer));
			dp.WriteCell(client);
			dp.WriteCell(item_id);
		}
		h_KvClientItems[client].Rewind();
		
		if (PlayerManager_IsItemToggledEx(client, sItemId))
		{
			ToggleItem(client, item_id, Toggle_On, true, true);
		}
	}
}

void PlayerManager_ClearPlayer(int client)
{
	if (h_KvClientItems[client] != null)
	{
		CloseHandle(h_KvClientItems[client]);
		h_KvClientItems[client] = null;
	}
	i_Id[client] = 0;
	iCredits[client] = 0;
}

void PlayerManager_OnClientDisconnect_Post(int client)
{
	if (!i_Id[client]) return;
	
	PlayerManager_SaveInfo(client, true);
	
	PlayerManager_ClearPlayer(client);
}

void PlayerManager_SaveInfo(int client, bool cleartimer = false)
{
	if (!i_Id[client]) return;
	
	char s_Query[256];
	int timeleft;
	char sItemId[16];
	FormatEx(s_Query, sizeof(s_Query), "UPDATE `%splayers` SET `money` = '%d' WHERE `id` = '%d';", g_sDbPrefix, iCredits[client], i_Id[client]);
	TQueryEx(s_Query, DBPrio_High);
	
	if (h_KvClientItems[client].GotoFirstSubKey())
	{
		do
		{
			if (!KvGetSectionName(h_KvClientItems[client], sItemId, sizeof(sItemId)))
				continue;
			
			int duration = h_KvClientItems[client].GetNum("duration");
			if (view_as<bool>(h_KvClientItems[client].GetNum("method")) == false)
			{
				timeleft = h_KvClientItems[client].GetNum("timeleft");
				int started = h_KvClientItems[client].GetNum("started", 0);
				if (started)
					timeleft = timeleft-(global_timer-started);
			}
			else
				timeleft = h_KvClientItems[client].GetNum("buy_time", 0)+duration-global_timer;
			
			if (cleartimer)
			{
				Handle timer = view_as<Handle>(h_KvClientItems[client].GetNum("timer", 0));
				if (timer != null)
				{
					KillTimer(timer);
					h_KvClientItems[client].SetNum("timer", 0);
				}
			}
			
			FormatEx(s_Query, sizeof(s_Query), "UPDATE `%sboughts` SET `count` = '%d', `duration` = '%d', `timeleft` = '%d', `buy_price` = '%d', `sell_price` = '%d' WHERE `player_id` = '%d' AND `item_id` = '%s';", g_sDbPrefix, h_KvClientItems[client].GetNum("count", 1), duration, timeleft, h_KvClientItems[client].GetNum("price"), h_KvClientItems[client].GetNum("sell_price"), i_Id[client], sItemId);
			TQueryEx(s_Query, DBPrio_High);
		}
		while (h_KvClientItems[client].GotoNextKey());
		
		h_KvClientItems[client].Rewind();
	}
}

void PlayerManager_OnItemRegistered(int item_id)
{
	char s_Query[256];
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!i_Id[client]) continue;
		
		FormatEx(s_Query, sizeof(s_Query), "SELECT `item_id`, `count`, `duration`, `timeleft`, `buy_price`, `sell_price`, `buy_time` FROM `%sboughts` WHERE `item_id` = '%i' AND `player_id` = '%i';", g_sDbPrefix, item_id, i_Id[client]);
		TQuery(PlayerManager_GetItemsFromDB, s_Query, GetClientSerial(client), DBPrio_Low);
	}
}

void PlayerManager_OnItemUnregistered(int item_id)
{
	char sItemId[16];
	IntToString(item_id, sItemId, sizeof(sItemId));
	
	char s_Query[256];
	
	int category_id = -1;
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!i_Id[client]) continue;
		
		if (h_KvClientItems[client].JumpToKey(sItemId))
		{
			int duration = h_KvClientItems[client].GetNum("duration");
			int started = h_KvClientItems[client].GetNum("started", 0);
			int timeleft = h_KvClientItems[client].GetNum("timeleft");
			
			if (started)
			{
				timeleft = timeleft-(global_timer-started);
				
				Handle timer = view_as<Handle>(h_KvClientItems[client].GetNum("timer", 0));
				if (timer != null)
				{
					KillTimer(timer);
					h_KvClientItems[client].SetNum("timer", 0);
				}
			}
			
			FormatEx(s_Query, sizeof(s_Query), "UPDATE `%sboughts` SET `count` = '%d', `duration` = '%d', `timeleft` = '%d', `buy_price` = '%d', `sell_price` = '%d' WHERE `player_id` = '%d' AND `item_id` = '%s';", g_sDbPrefix, h_KvClientItems[client].GetNum("count", 1), duration, timeleft, h_KvClientItems[client].GetNum("price"), h_KvClientItems[client].GetNum("sell_price"), i_Id[client], sItemId);
			TQueryEx(s_Query, DBPrio_High);
			
			category_id = h_KvClientItems[client].GetNum("category_id", -1);
			
			h_KvClientItems[client].DeleteThis();
			h_KvClientItems[client].Rewind();
			
			IntToString(category_id, sItemId, sizeof(sItemId));
			StrCat(sItemId, sizeof(sItemId), "c");
			h_KvClientItems[client].SetNum(sItemId, h_KvClientItems[client].GetNum(sItemId, 0)-1);
			
			//NotifyItemOff(client, item_id);
		}
	}
}

int PlayerManager_GetCredits(int client)
{
	return iCredits[client];
}

stock void PlayerManager_SetCredits(int client, int credits)
{
	if (credits < 0)
		credits = 0;
	
	iCredits[client] = credits;
	
	char s_Query[256];
	FormatEx(s_Query, sizeof(s_Query), "UPDATE `%splayers` SET `money` = '%d' WHERE `id` = '%d';", g_sDbPrefix, iCredits[client], i_Id[client]);
	TQueryEx(s_Query, DBPrio_High);
}

void PlayerManager_GiveCredits(int client, int credits)
{
	iCredits[client] += credits;
	
	char s_Query[256];
	FormatEx(s_Query, sizeof(s_Query), "UPDATE `%splayers` SET `money` = '%d' WHERE `id` = '%d';", g_sDbPrefix, iCredits[client], i_Id[client]);
	TQueryEx(s_Query, DBPrio_High);
}

void PlayerManager_RemoveCredits(int client, int credits)
{
	iCredits[client] -= credits;
	if (iCredits[client] < 0)
		iCredits[client] = 0;
	
	char s_Query[256];
	FormatEx(s_Query, sizeof(s_Query), "UPDATE `%splayers` SET `money` = '%d' WHERE `id` = '%d';", g_sDbPrefix, iCredits[client], i_Id[client]);
	TQueryEx(s_Query, DBPrio_High);
}