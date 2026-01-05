import express from "express";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json());

/**
 * POST /ai/suggest-category
 * body: { type: 0|1, note: string, categories: [{id,name}] }
 * res:  { categoryId, confidence, reason }
 */
app.post("/ai/suggest-category", (req, res) => {
  const { type, note, categories } = req.body;

  const text = String(note || "").toLowerCase();

  // Rules demo (bạn sửa theo ý)
  const rules = [
    { keys: ["ăn", "cafe", "highland", "phở", "bún", "trà sữa", "coffee"], id: "exp_food" },
    { keys: ["xăng", "grab", "taxi", "bus", "xe", "gửi xe", "parking"], id: "exp_transport" },
    { keys: ["điện", "nước", "wifi", "internet", "netflix", "spotify"], id: "exp_bills" },
    { keys: ["mua", "shopping", "shopee", "lazada", "áo", "quần"], id: "exp_shopping" },
    { keys: ["phim", "movie", "game", "giải trí"], id: "exp_entertainment" },

    { keys: ["lương", "salary", "payroll"], id: "inc_salary" },
    { keys: ["kinh doanh", "business", "bán hàng"], id: "inc_business" },
    { keys: ["tặng", "gift", "lì xì"], id: "inc_gift" },
  ];

  // pick by rule
  let pick = null;
  for (const r of rules) {
    if (r.keys.some((k) => text.includes(k))) {
      pick = r.id;
      break;
    }
  }

  // fallback: pick first category that matches type from provided categories
  if (!pick && Array.isArray(categories)) {
    // Optionally: you can filter by id prefix exp_/inc_
    const fallback = categories[0];
    pick = fallback?.id ?? null;
  }

  res.json({
    categoryId: pick,
    confidence: pick ? 0.82 : 0.0,
    reason: pick
      ? `Gợi ý dựa trên note: "${note}"`
      : "Không đủ thông tin để gợi ý.",
  });
});

app.get("/health", (_, res) => res.json({ ok: true }));

app.listen(3000, () => {
  console.log("✅ AI mock server running at http://localhost:3000");
});
