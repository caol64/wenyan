import type { ArticleStorageAdapter, Article } from "@wenyan-md/ui";
import { invokeSwift } from "../bridge";

export const userDefaultsArticleStorageAdapter: ArticleStorageAdapter = {
    async load(): Promise<Article[]> {
        const content = await invokeSwift<string>("loadArticles", null, true);
        return content ? [{
            id: "last-article",
            title: "Last Article",
            content,
            created: Date.now(),
        }] : [];
    },
    async save(article: Article): Promise<void> {
        return invokeSwift<void>("saveArticle", article.content);
    },
    async remove(id: string): Promise<void> {

    },
};
