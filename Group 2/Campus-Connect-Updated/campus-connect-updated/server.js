import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json({ limit: '20mb' }));

mongoose.connect('mongodb://localhost:27017/campus-connect')
  .then(() => {
    console.log('✅ MongoDB connected');
    seedIfEmpty();
    seedConversations();
  })
  .catch(err => console.error('❌ Error:', err));

// ─── SCHEMAS ───────────────────────────────────────────

const ItemSchema = new mongoose.Schema({
  type: { type: String, enum: ['lost', 'found'], required: true },
  title: { type: String, required: true },
  description: String,
  category: String,
  brand: String,
  building: String,
  floor: String,
  image: String,
  ownerId: String,
  ownerName: String,
  ownerInitials: String,
  status: { type: String, default: 'active' },
  timeAgo: String,
  createdAt: String,
}, { timestamps: false });

const ConversationSchema = new mongoose.Schema({
  contactName: String,
  contactInitials: String,
  contactColor: String,
  itemTag: String,
  lastMessage: String,
  timestamp: String,
  unread: { type: Number, default: 0 },
  online: { type: Boolean, default: false },
});

const ChatMessageSchema = new mongoose.Schema({
  conversationId: { type: String, required: true },
  senderId: String,
  text: String,
  timestamp: String,
  isMe: Boolean,
}, { timestamps: true });

const Item = mongoose.model('Item', ItemSchema);
const Conversation = mongoose.model('Conversation', ConversationSchema);
const ChatMessage = mongoose.model('ChatMessage', ChatMessageSchema);

// ─── SEEDS ─────────────────────────────────────────────

const seedIfEmpty = async () => {
  const count = await Item.countDocuments();
  if (count > 0) return;
  await Item.insertMany([
    {
      type: "lost", title: 'MacBook Pro 14"',
      description: "Left my laptop on the wooden desk near the windows in the 3rd-floor quiet zone. It has a 'University Engineering' sticker on the top right corner.",
      category: "Electronics", brand: "Apple", building: "Main Library", floor: "3rd Floor, Quiet Zone",
      image: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&h=400&fit=crop",
      ownerId: "u1", ownerName: "John Doe", ownerInitials: "JD", status: "active", timeAgo: "10m ago", createdAt: "2026-02-27T10:00:00Z"
    },
    {
      type: "found", title: "Blue HydroFlask",
      description: "Found this on one of the couches near the food court. Turned it in to the front desk. Navy blue with some stickers.",
      category: "Accessories", brand: "HydroFlask", building: "Student Union", floor: "Ground Floor",
      image: "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=600&h=400&fit=crop",
      ownerId: "u2", ownerName: "Alice Smith", ownerInitials: "AS", status: "active", timeAgo: "45m ago", createdAt: "2026-02-27T08:00:00Z"
    },
    {
      type: "found", title: "Leather Wallet (Brown)",
      description: "Brown leather wallet found near the vending machines in Engineering Block C. Contains some cards.",
      category: "Accessories", brand: "Unknown", building: "Engineering Block C", floor: "1st Floor",
      image: "https://images.unsplash.com/photo-1627123424574-724758594e93?w=600&h=400&fit=crop",
      ownerId: "u3", ownerName: "Mike Ross", ownerInitials: "MR", status: "active", timeAgo: "2h ago", createdAt: "2026-02-27T06:00:00Z"
    },
    {
      type: "lost", title: "Sony WH-1000XM4",
      description: "Left my headphones on the table at Cafeteria Terrace. Black Sony noise-cancelling headphones with a red carrying case.",
      category: "Electronics", brand: "Sony", building: "Cafeteria", floor: "Terrace",
      image: "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=600&h=400&fit=crop",
      ownerId: "u4", ownerName: "Rachel Lee", ownerInitials: "RL", status: "active", timeAgo: "5h ago", createdAt: "2026-02-27T03:00:00Z"
    },
    {
      type: "lost", title: "AirPods Pro Case",
      description: "Lost an empty AirPods Pro case near the treadmills. White with a small scratch on the lid.",
      category: "Electronics", brand: "Apple", building: "Gym", floor: "Cardio Area",
      image: "https://images.unsplash.com/photo-1588423771073-b8903fba2b02?w=600&h=400&fit=crop",
      ownerId: "u5", ownerName: "Sam Wilson", ownerInitials: "SW", status: "active", timeAgo: "1d ago", createdAt: "2026-02-26T10:00:00Z"
    },
    {
      type: "found", title: "Student ID Card",
      description: "Found a student ID card near the entrance of Science Building. Name partially visible.",
      category: "IDs", brand: "University", building: "Science Building", floor: "Entrance",
      image: "https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=600&h=400&fit=crop",
      ownerId: "u6", ownerName: "Prof. Davis", ownerInitials: "PD", status: "active", timeAgo: "18h ago", createdAt: "2026-02-26T14:00:00Z"
    },
  ]);
  console.log('🌱 Items seeded into MongoDB');
};

const seedConversations = async () => {
  const count = await Conversation.countDocuments();
  if (count > 0) return;
  const seeded = await Conversation.insertMany([
    { contactName: "Marcus Chen", contactInitials: "MC", contactColor: "hsl(174, 80%, 50%)", itemTag: "MacBook Air M2", lastMessage: "I found it near the library cafe!", timestamp: "2m ago", unread: 1, online: true },
    { contactName: "Sarah Jenkins", contactInitials: "SJ", contactColor: "hsl(340, 65%, 60%)", itemTag: "Silver Keychain", lastMessage: "Are these yours? I'm at the Student Un...", timestamp: "15m ago", unread: 2, online: false },
    { contactName: "Campus Security", contactInitials: "CS", contactColor: "hsl(145, 63%, 60%)", itemTag: "Official Notice", lastMessage: "Your item has been verified for pickup.", timestamp: "1h ago", unread: 0, online: true },
    { contactName: "David Miller", contactInitials: "DM", contactColor: "hsl(200, 60%, 55%)", itemTag: "Apple Watch S8", lastMessage: "Thanks again for returning it!", timestamp: "3h ago", unread: 0, online: false },
    { contactName: "Elena Rodriguez", contactInitials: "ER", contactColor: "hsl(280, 60%, 60%)", itemTag: "Physics Textbook", lastMessage: "Is the cover blue or black?", timestamp: "Yesterday", unread: 0, online: false },
  ]);
  const firstId = seeded[0]._id.toString();
  await ChatMessage.insertMany([
    { conversationId: firstId, senderId: "u2", text: "Hey! I think I found your MacBook at the library cafe.", timestamp: "2:30 PM", isMe: false },
    { conversationId: firstId, senderId: "u1", text: "Oh really? That would be amazing! Can you describe it?", timestamp: "2:31 PM", isMe: true },
    { conversationId: firstId, senderId: "u2", text: "It's a 14-inch MacBook Pro, space grey, has an engineering sticker on the top right.", timestamp: "2:32 PM", isMe: false },
    { conversationId: firstId, senderId: "u1", text: "Yes! That's mine! Where exactly did you find it?", timestamp: "2:33 PM", isMe: true },
    { conversationId: firstId, senderId: "u2", text: "It was on a table near the windows on the 3rd floor. I turned it in to the front desk.", timestamp: "2:34 PM", isMe: false },
    { conversationId: firstId, senderId: "u1", text: "Thank you so much! I'll head there right now.", timestamp: "2:35 PM", isMe: true },
  ]);
  console.log('🌱 Conversations seeded into MongoDB');
};

// ─── ITEM ROUTES ───────────────────────────────────────

app.get('/api/items', async (req, res) => {
  const items = await Item.find().sort({ createdAt: -1 });
  res.json(items.map(i => ({ ...i.toObject(), id: i._id })));
});

app.post('/api/items', async (req, res) => {
  const item = await Item.create(req.body);
  res.status(201).json({ ...item.toObject(), id: item._id });
});

app.delete('/api/items/:id', async (req, res) => {
  await Item.findByIdAndDelete(req.params.id);
  res.json({ success: true });
});

// ─── CONVERSATION ROUTES ───────────────────────────────

app.get('/api/conversations', async (req, res) => {
  const convs = await Conversation.find();
  res.json(convs.map(c => ({ ...c.toObject(), id: c._id })));
});

app.get('/api/conversations/:id/messages', async (req, res) => {
  const msgs = await ChatMessage.find({ conversationId: req.params.id }).sort({ createdAt: 1 });
  res.json(msgs.map(m => ({ ...m.toObject(), id: m._id })));
});

app.post('/api/conversations/:id/messages', async (req, res) => {
  const msg = await ChatMessage.create({ ...req.body, conversationId: req.params.id });
  await Conversation.findByIdAndUpdate(req.params.id, {
    lastMessage: req.body.text,
    timestamp: "Just now",
  });
  res.status(201).json({ ...msg.toObject(), id: msg._id });
});

// ───────────────────────────────────────────────────────

app.listen(5000, () => console.log('🚀 Server on http://localhost:'));