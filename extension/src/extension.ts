// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from 'vscode';
import * as fs from "fs";
import * as path from "path";

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {

	// The command has been defined in the package.json file
	// Now provide the implementation of the command with registerCommand
	// The commandId parameter must match the command field in package.json
	const disposable = vscode.commands.registerCommand('commancode-vscode.showPlan', async () => {
		// The code you place here will be executed every time your command is executed
		// Display a message box to the user
		const commandCodePlansDir = path.join(process.env.HOME || "", ".commandcode" , "plans");
		let planFiles = fs.readdirSync(commandCodePlansDir, "utf-8");
		const plansIndexFile = path.join(commandCodePlansDir, "plans-index.json");
		planFiles = planFiles.filter((f) => f !== path.basename(plansIndexFile));
		const plansIndexContents = fs.readFileSync(plansIndexFile , 'utf-8');
		const existingPlans = Object.keys(JSON.parse(plansIndexContents)["plans"]);
		if (planFiles.length === existingPlans.length && planFiles.every(f => existingPlans.includes(f))) {
			const document = vscode.Uri.file(path.join(commandCodePlansDir , existingPlans.pop() as string));
			await vscode.window.showTextDocument(document);
		}
		else{
			const missingPlan = planFiles.find((f) => !existingPlans.includes(f));
			if (missingPlan) {
				const document = vscode.Uri.file(path.join(commandCodePlansDir, missingPlan));
				await vscode.window.showTextDocument(document);
			}
		}
	});

	context.subscriptions.push(disposable);
}

// This method is called when your extension is deactivated
export function deactivate() {}
