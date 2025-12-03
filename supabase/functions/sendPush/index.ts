import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { SignJWT } from "https://deno.land/x/jose@v4.14.4/index.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS"
};

// 🔥 PEM → PKCS8 Uint8Array 변환
function pemToBinary(pem: string) {
  const cleaned = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\r/g, "")
    .replace(/\n/g, "")
    .replace(/\s+/g, "")
    .trim();

  const binary = atob(cleaned);
  const buffer = new Uint8Array(binary.length);

  for (let i = 0; i < binary.length; i++) {
    buffer[i] = binary.charCodeAt(i);
  }

  return buffer;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders
    });
  }

  try {
    const { mode, testToken, title, body } = await req.json();

    // ---------------------------------------------------------
    // 🔥 1) 환경 변수 로드
    // ---------------------------------------------------------
    const serviceAccountJson = Deno.env.get("SERVICE_ACCOUNT_JSON");
    if (!serviceAccountJson) {
      throw new Error("SERVICE_ACCOUNT_JSON not set");
    }

    const projectId = Deno.env.get("PROJECT_ID");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    let serviceAccount = JSON.parse(serviceAccountJson);

    // 🔥 private_key 줄바꿈 복구
    serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");

    // ---------------------------------------------------------
    // 🔥 2) Google OAuth JWT 생성
    // ---------------------------------------------------------
    const privateKeyBinary = pemToBinary(serviceAccount.private_key);

    const key = await crypto.subtle.importKey(
      "pkcs8",
      privateKeyBinary,
      {
        name: "RSASSA-PKCS1-v1_5",
        hash: "SHA-256"
      },
      false,
      ["sign"]
    );

    const now = Math.floor(Date.now() / 1000);

    const jwt = await new SignJWT({
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600
    })
      .setProtectedHeader({
        alg: "RS256",
        typ: "JWT"
      })
      .sign(key);

    // ---------------------------------------------------------
    // 🔥 3) Access Token 요청
    // ---------------------------------------------------------
    const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: jwt
      })
    });

    const tokenJson = await tokenRes.json();
    const access_token = tokenJson.access_token;

    if (!access_token) {
      console.error("🔥 ACCESS TOKEN ERROR:", tokenJson);
      throw new Error("Failed to obtain access_token");
    }

    // ---------------------------------------------------------
    // 🔥 4) 토큰 목록 불러오기
    // ---------------------------------------------------------
    let tokens: string[] = [];

    if (mode === "test") {
      tokens = [testToken];
    } else {
      const list = await fetch(`${supabaseUrl}/rest/v1/fcm_tokens?select=token`, {
        headers: {
          apikey: supabaseKey,
          Authorization: `Bearer ${supabaseKey}`
        }
      }).then((r) => r.json());

      tokens = list.map((row: any) => row.token);
    }

    // ---------------------------------------------------------
    // 🔥 5) FCM 발송 + 에러 로그 출력
    // ---------------------------------------------------------
    let success = 0;
    let fail = 0;
    const failedTokens: Array<any> = [];

    for (const token of tokens) {
      const fcmRes = await fetch(
        `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${access_token}`,
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            message: {
              token,
              notification: { title, body },
              data: { route: "/intro" }
            }
          })
        }
      );

      if (fcmRes.ok) {
        success++;
      } else {
        fail++;

        const errorText = await fcmRes.text();
        console.error("🔥 FCM ERROR:", errorText);

        failedTokens.push({
          token,
          error: errorText
        });
      }
    }

    // ---------------------------------------------------------
    // 🔥 6) 로그 저장
    // ---------------------------------------------------------
    await fetch(`${supabaseUrl}/rest/v1/push_logs`, {
      method: "POST",
      headers: {
        apikey: supabaseKey,
        Authorization: `Bearer ${supabaseKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        mode,
        title,
        body,
        target_count: tokens.length,
        success_count: success,
        fail_count: fail,
        details: failedTokens,
        created_at: new Date().toISOString()
      })
    });

    return new Response(
      JSON.stringify({
        status: "ok",
        success,
        fail,
        total: tokens.length,
        errors: failedTokens
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      }
    );
  } catch (e) {
    console.error("🔥 FUNCTION CATCH ERROR:", e);

    return new Response(
      JSON.stringify({
        error: `${e}`
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      }
    );
  }
});
